extends KinematicBody2D
class_name Player

signal player_state_changed(old_state_enum, new_state_enum)
signal player_hit_hazard

export(NodePath) var starting_room_path = ""

# The possible states that the player can be in. The NO_CHANGE state is reserved
# for states indicating that the current state should not be changed and does
# not itself constitute a valid player state.
enum State {
    NO_CHANGE,
    IDLE,
    WALK,
    JUMP,
    DOUBLE_JUMP,
    FALL,
    DASH,
    WALL_SLIDE,
    WALL_JUMP,
    GRAPPLE_START,
    GRAPPLE,
    STAGGER,
    HAZARD_HIT,
    HAZARD_RECOVER,
}

# Maps State enum to corresponding state scripts.
onready var STATES = {
    State.IDLE:           $States/Idle,
    State.WALK:           $States/Walk,
    State.JUMP:           $States/Jump,
    State.DOUBLE_JUMP:    $States/DoubleJump,
    State.FALL:           $States/Fall,
    State.DASH:           $States/Dash,
    State.WALL_SLIDE:     $States/WallSlide,
    State.WALL_JUMP:      $States/WallJump,
    State.GRAPPLE_START:  $States/GrappleStart,
    State.GRAPPLE:        $States/Grapple,
    State.STAGGER:        $States/Stagger,
    State.HAZARD_HIT:     $States/HazardHit,
    State.HAZARD_RECOVER: $States/HazardRecover,
}

var current_state: Node = null
var current_state_enum: int = -1

# Vector denoting the 2D movement to be applied to the player during each
# update() call, measured in pixels per second.
var velocity: Vector2 = Vector2.ZERO

# The amount of time to wait after completing a dash before dashing again.
const DASH_COOLDOWN: float = 0.30

# The original positions of all "y-axis mirrored" nodes.
var _mirror_y_axis_node_original_positions: Dictionary = {}

# An array of body RIDs that the player hits during an attack. This is used to
# prevent enemies taking more than one hit per attack, which is possible if e.g.
# an enemy is staggers out of the player's hitbox and then moves back into it
# before the hitbox is disabled. This array is cleared at the start of each
# attack animation.
var _enemies_hit := []

onready var _sprite: Sprite = $Sprite

onready var _animation_player: AnimationPlayer = $AnimationPlayer

onready var _dash_cooldown_timer: Timer = $DashCooldown

onready var _camera_anchor: Position2D = $CameraAnchor

onready var _wall_proximity_detector: Node2D = $WallProximityDetector

onready var _floor_proximity_detector: RayCast2D = $FloorProximityDetector

onready var _wall_slide_trail_effect: Particles2D = $WallSlideTrail

onready var _grapple_rope: Line2D = $GrappleRope
onready var _grapple_line_of_sight: RayCast2D = $GrappleLineOfSight

onready var _health: Health = $Health
onready var _hitbox: Area2D = $AttackHitbox
onready var _hurtbox: Area2D = $Hurtbox

onready var _invincibility_flash_manager: Node = $FlashManager

onready var _physics_manager: PhysicsManager = $PhysicsManager

onready var _dash_duration_timer: Timer = $States/Dash/DashDurationTimer
onready var _dash_echo_timer: Timer = $States/Dash/DashEchoTimer

onready var _stagger_duration_timer: Timer = $States/Stagger/StaggerDurationTimer

# The grapple point to be used the next time the player presses the grapple
# button. This is updated on every frame based on several candidacy rules. If
# there are no valid grapple points for the player on a given frame, this is set
# to null and grappling has no effect.
var _next_grapple_point: GrapplePoint = null

var _nearby_sign = null

var _current_hazard_checkpoint: Area2D = null

# Keep track of the current room the player is in, as well as the previous room
# the player was in, to assist in room transitions.
var prev_room = null
var curr_room = null

var _can_dash: bool = true

var _jumps_remaining: int = 2

func _get_configuration_warning() -> String:
    if starting_room_path == '':
        return "Please specify the player's starting room."
    return ''

func _ready() -> void:
    # Create a dash cooldown timer.
    _dash_cooldown_timer.wait_time = DASH_COOLDOWN
    _dash_cooldown_timer.one_shot = true

    # Begin in fall state
    current_state_enum = State.FALL
    current_state = STATES[current_state_enum]
    change_state({'new_state': State.FALL})

    # Initialize current room
    assert(starting_room_path != '')
    curr_room = get_node(starting_room_path)
    prev_room = curr_room
    get_camera().fit_camera_limits_to_room(curr_room)

    # Save the current positions of all "y-axis mirrored" nodes so that they can
    # all be mirrored at once when the player changes direction.
    for node in get_tree().get_nodes_in_group('mirror_y_axis'):
        _mirror_y_axis_node_original_positions[node] = node.get_position()

    _invincibility_flash_manager.connect(
        'flashing_finished', self, '_on_invincibility_flashing_finished')

    _hitbox.connect('area_entered', self, '_on_attack_connected')

func _unhandled_input(event: InputEvent) -> void:
    var new_state_dict = current_state.handle_input(self, event)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        change_state(new_state_dict)

func _physics_process(delta: float) -> void:
    _update_next_grapple_point()

    _check_for_hits()

    var new_state_dict = current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        change_state(new_state_dict)

# Change from one state in the state machine to another.
func change_state(new_state_dict: Dictionary) -> void:
    var old_state_enum := current_state_enum
    var new_state_enum: int = new_state_dict['new_state']

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = old_state_enum

    current_state.exit(self)
    current_state_enum = new_state_enum
    current_state = STATES[new_state_enum]
    current_state.enter(self, new_state_dict)

    emit_signal('player_state_changed', old_state_enum, new_state_enum)

func current_state() -> int:
    return current_state_enum

func get_physics_manager() -> PhysicsManager:
    return _physics_manager

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    self.velocity = .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func is_on_ground() -> bool:
    return .is_on_floor()

func is_in_air() -> bool:
    return not is_on_ground()

# Detects whether the player is currently colliding with the way (i.e. whether
# the player is actively pressing up against it). This is useful for initiating
# a wall slide so that e.g. the player can jump near walls if they're not
# pressed up against them.
func is_on_wall() -> bool:
    return .is_on_wall()

# Detects whether the player is close to a wall without necessarily directly
# colliding with it. This is useful for making quick consecutive wall jumps feel
# more comfortable by not requiring the player to connect with the wall for a
# frame before continuing the wall jump chain.
func is_near_wall_front() -> bool:
    return _wall_proximity_detector.is_near_wall_front()
func is_near_wall_back() -> bool:
    return _wall_proximity_detector.is_near_wall_back()

# Gets the wall normal if either set of raycasts is colliding with the wall, or
# Vector2.ZERO otherwise. Useful for ensuring proper player direction when
# performing wall jumps.
func get_wall_normal_front() -> Vector2:
    return _wall_proximity_detector.get_wall_normal_front()
func get_wall_normal_back() -> Vector2:
    return _wall_proximity_detector.get_wall_normal_back()

func start_attack() -> void:
    _enemies_hit.clear()
    get_animation_player().play('attack')

func is_attacking() -> bool:
    return get_animation_player().current_animation == 'attack'

# Flush animation queue so that we can cancel attack animations cleanly.
func stop_attack() -> void:
    get_animation_player().clear_queue()

func get_health() -> Health:
    return _health

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_camera() -> Camera2D:
    return _camera_anchor.get_node('Camera2D') as Camera2D

func get_dash_cooldown_timer() -> Timer:
    return _dash_cooldown_timer as Timer

func get_wall_slide_trail() -> Particles2D:
    return _wall_slide_trail_effect

func get_grapple_rope() -> Line2D:
    return _grapple_rope

func get_direction() -> int:
    return -1 if _sprite.flip_h else 1

func set_direction(direction: int) -> void:
    # Flip player sprite.
    _sprite.flip_h = (direction == -1)

    # Flip wall detector raycasts.
    if direction in [-1, 1]:
        _wall_proximity_detector.set_direction(direction)

    # Flip all "y-axis mirrored" nodes.
    if direction in [-1, 1]:
        for node in get_tree().get_nodes_in_group('mirror_y_axis'):
            var original_position = _mirror_y_axis_node_original_positions[node]
            node.position.x = original_position.x * direction

func set_nearby_sign(new_sign: Area2D) -> void:
    _nearby_sign = new_sign
func get_nearby_sign() -> Area2D:
    return _nearby_sign

func set_hazard_checkpoint(hazard_checkpoint: Area2D) -> void:
    _current_hazard_checkpoint = hazard_checkpoint
func get_hazard_checkpoint() -> Area2D:
    return _current_hazard_checkpoint

# Pause/resume processing for player node specifically. Used during room
# transitions.
func pause() -> void:
    set_physics_process(false)
    set_process_unhandled_input(false)

    get_animation_player().stop(false)

    _invincibility_flash_manager.pause_timer()

    _dash_cooldown_timer.paused = true

    _dash_duration_timer.paused = true
    _dash_echo_timer.paused = true
    _stagger_duration_timer.paused = true
func unpause() -> void:
    set_physics_process(true)
    set_process_unhandled_input(true)

    get_animation_player().play()

    _invincibility_flash_manager.resume_timer()

    _dash_cooldown_timer.paused = false

    _dash_duration_timer.paused = false
    _dash_echo_timer.paused = false
    _stagger_duration_timer.paused = false

# Functions providing a more readable and convenient interface for managing
# dashes.
func can_dash() -> bool:
    return _can_dash
func consume_dash() -> void:
    _can_dash = false
func reset_dash() -> void:
    _can_dash = true

func can_jump() -> bool:
    return _jumps_remaining > 0
func consume_jump() -> void:
    _jumps_remaining -= 1
func reset_jump() -> void:
    _jumps_remaining = 2

# Conceptually, we want to know whether the player is simultaneously on the
# floor and on the ceiling to detect whether we're being crushed by a moving
# platform. Checking for both .is_on_floor() and .is_on_ceiling() doesn't work,
# as physics bodies are likely not allowed to be colliding with objects in
# opposite directions at the same time. Therefore, we use a ray cast to check
# for collisions with the floor and .is_on_ceiling() to detect collisions with
# the ceiling.
func _is_being_crushed() -> bool:
    return _floor_proximity_detector.is_colliding() and .is_on_ceiling()

func _check_for_hits() -> void:
    var player_health := get_health()

    # Treat being crushed by e.g. moving platform as a hazard hit.
    if _is_being_crushed():
        var damage_taken := player_health.take_damage(1)
        if damage_taken:
            player_health.set_status(Health.Status.INVINCIBLE)
            _invincibility_flash_manager.start_flashing()
            change_state({'new_state': State.HAZARD_HIT})
            emit_signal('player_hit_hazard')

    for hitbox in _hurtbox.get_overlapping_areas():
        if Util.in_collision_layers(hitbox, ['hazards', 'enemy_hitbox']):
            # Take damage and stagger when hit.
            var damage_taken := player_health.take_damage(1)
            if damage_taken:
                player_health.set_status(Health.Status.INVINCIBLE)
                _invincibility_flash_manager.start_flashing()

                if Util.in_collision_layer(hitbox, 'hazards'):
                    change_state({'new_state': State.HAZARD_HIT})
                    emit_signal('player_hit_hazard')
                elif Util.in_collision_layer(hitbox, 'enemy_hitbox'):
                    change_state({'new_state': State.STAGGER})

func get_next_grapple_point() -> GrapplePoint:
    return _next_grapple_point

func _update_next_grapple_point() -> void:
    _next_grapple_point = null

    # Determine candidate set of grapple points and reset grapple point colors.
    var candidate_grapple_points := []
    for grapple_point in curr_room.get_grapple_points():
        grapple_point.get_node('Sprite').modulate = Color.white
        if _can_grapple_to(grapple_point):
            candidate_grapple_points.append(grapple_point)

    # Sort candidate grapple points by distance to player.
    candidate_grapple_points.sort_custom(self, '_grapple_distance_comparator')

    # Pick the first grapple point that the player is facing. If the player is
    # facing away from all available grapple points, pick the closest one.
    if not candidate_grapple_points.empty():
        _next_grapple_point = candidate_grapple_points[0]
        for grapple_point in candidate_grapple_points:
            var grapple_point_direction := Util.direction(self, grapple_point)
            if self.get_direction() == grapple_point_direction:
                _next_grapple_point = grapple_point
                break

    # Color the next grapple point green.
    if _next_grapple_point:
        _next_grapple_point.get_node('Sprite').modulate = Color.green

func _grapple_point_in_line_of_sight(grapple_point: GrapplePoint) -> bool:
    _grapple_line_of_sight.set_cast_to(
        _grapple_line_of_sight.to_local(
            grapple_point.get_attachment_pos().global_position))
    _grapple_line_of_sight.force_raycast_update()
    return not _grapple_line_of_sight.is_colliding()

func _grapple_point_in_range(grapple_point: GrapplePoint) -> bool:
    return grapple_point.get_grapple_range_area().overlaps_body(self)

func _player_in_no_grapple_area(grapple_point: GrapplePoint) -> bool:
    return grapple_point.get_no_grapple_area().overlaps_body(self)

func _grapple_point_on_screen(grapple_point: GrapplePoint) -> bool:
    return grapple_point.is_on_screen()

func _can_grapple_to(grapple_point: GrapplePoint) -> bool:
    if not grapple_point.is_available():
        return false

    if not _grapple_point_in_line_of_sight(grapple_point):
        return false

    if not _grapple_point_in_range(grapple_point):
        return false

    if _player_in_no_grapple_area(grapple_point):
        return false

    if not _grapple_point_on_screen(grapple_point):
        return false

    return true

func _grapple_distance_comparator(a: GrapplePoint, b: GrapplePoint) -> bool:
    var distance_to_a := a.global_position.distance_to(self.global_position)
    var distance_to_b := b.global_position.distance_to(self.global_position)
    return distance_to_a < distance_to_b

func _on_invincibility_flashing_finished() -> void:
    get_health().set_status(Health.Status.NONE)

func _on_attack_connected(enemy_hurtbox: Area2D) -> void:
    var enemy_hurtbox_rid := enemy_hurtbox.get_rid().get_id()
    if enemy_hurtbox_rid in _enemies_hit:
        return
    _enemies_hit.append(enemy_hurtbox_rid)

    # TODO: This is kind of hacky, find a way around this.
    enemy_hurtbox.get_parent().take_hit(1, self)