extends KinematicBody2D
class_name Player

signal player_state_changed(old_state_enum, new_state_enum)
signal player_hit_hazard
signal player_walked_to_point

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
    REST,
    WALK_TO_POINT,
    HARD_LANDING,
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
    State.REST:           $States/Rest,
    State.WALK_TO_POINT:  $States/WalkToPoint,
    State.HARD_LANDING:   $States/HardLanding,
}

var current_state: Node = null
var current_state_enum: int = -1

# Vector denoting the 2D movement to be applied to the player during each
# update() call, measured in pixels per second.
var velocity: Vector2 = Vector2.ZERO

# The original positions of all "y-axis mirrored" nodes.
var _mirror_y_axis_node_original_positions: Dictionary = {}

# An array of body RIDs that the player hits during an attack. This is used to
# prevent enemies taking more than one hit per attack, which is possible if e.g.
# an enemy is staggers out of the player's hitbox and then moves back into it
# before the hitbox is disabled. This array is cleared at the start of each
# attack animation.
var _enemies_hit := []

# For some reason, calling AnimationPlayer::stop(false) in pause() causes the
# animation queue to flush. This is problematic if attacking into a screen
# transition, as the queued animation (usually walk) is never played after
# resume() is called. Use this array to manually save and restore the animation
# queue when pausing and resuming.
#
# TODO: Submitted https://github.com/godotengine/godot/issues/36279, so if that
#       gets addressed then remove this workaround.
var _animation_queue := []

onready var _sprite: Sprite = $Sprite

onready var _animation_player: AnimationPlayer = $AnimationPlayer

onready var _camera: Camera2D = $CameraAnchor/Camera2D

onready var _wall_proximity_detector: Node2D = $WallProximityDetector

onready var _floor_proximity_detector: RayCast2D = $FloorProximityDetector

onready var _wall_slide_trail_effect: Particles2D = $WallSlideTrail
onready var _dust_puff: Particles2D = $DustPuff
onready var _dash_puff: Particles2D = $DashPuff

onready var _grapple_rope: Line2D = $GrappleRope
onready var _grapple_hook: Sprite = $GrappleHook
onready var _grapple_line_of_sight: RayCast2D = $GrappleLineOfSight

onready var _health: Health = $Health
onready var _hitboxes: Node2D = $Hitboxes
onready var _hurtbox: Area2D = $Hurtbox

onready var _invincibility_flash_manager: Node = $FlashManager

onready var _physics_manager: GroundedPhysicsManager = $PhysicsManager

onready var _dash_duration_timer: Timer = $States/Dash/DashDurationTimer
onready var _dash_echo_timer: Timer = $States/Dash/DashEchoTimer

onready var _stagger_duration_timer: Timer = $States/Stagger/StaggerDurationTimer

onready var _fall_time_stopwatch: Stopwatch = $States/Fall/FallTimeStopwatch

onready var _jump_manager: JumpManager = $JumpManager
onready var _dash_manager: DashManager = $DashManager

# The grapple point to be used the next time the player presses the grapple
# button. This is updated on every frame based on several candidacy rules. If
# there are no valid grapple points for the player on a given frame, this is set
# to null and grappling has no effect.
var _next_grapple_point: GrapplePoint = null

var _nearby_sign = null
var _nearby_lamp = null

var _current_hazard_checkpoint: Area2D = null

# Keep track of the current room the player is in, as well as the previous room
# the player was in, to assist in room transitions.
var prev_room = null
var curr_room = null

func _ready() -> void:
    # Begin in fall state
    current_state_enum = State.FALL
    current_state = STATES[current_state_enum]
    change_state({'new_state': State.FALL})

    # Save the current positions of all "y-axis mirrored" nodes so that they can
    # all be mirrored at once when the player changes direction.
    for node in get_tree().get_nodes_in_group('mirror_y_axis'):
        _mirror_y_axis_node_original_positions[node] = node.get_position()

    _invincibility_flash_manager.connect(
        'flashing_finished', self, '_on_invincibility_flashing_finished')

    for hitbox in _hitboxes.get_children():
        hitbox.connect('area_entered', self, '_on_attack_connected')

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

func get_physics_manager() -> GroundedPhysicsManager:
    return _physics_manager

# Get the current x-axis input direction. Returns +1 if player is moving right,
# -1 if player is moving left, and 0 if player is not moving. These conveniently
# correspond to Util.Direction.RIGHT, Util.Direction.LEFT, and
# Util.Direction.NONE, respectively.
func get_input_direction() -> int:
    # In situations where we explicitly set_process_unhandled_input(false), we
    # also want to disable movement inputs as well, since those calls to
    # get_input_direction() happen in each state's update() function instead of
    # the handle_input() function that _unhandled_input(event) forwards to.
    if not is_processing_unhandled_input():
        return 0

    # For now, just calculate movement on the x-axis.
    return int(Input.is_action_pressed('player_move_right')) - \
           int(Input.is_action_pressed('player_move_left'))

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

func emit_dust_puff() -> void:
    _dust_puff.restart()

func emit_dash_puff() -> void:
    _dash_puff.restart()

func start_attack(attack_animation_name: String = 'attack') -> void:
    _enemies_hit.clear()
    get_animation_player().play(attack_animation_name)

func is_attacking() -> bool:
    return get_animation_player().current_animation in ['attack', 'attack_up']

# Flush animation queue so that we can cancel attack animations cleanly.
func stop_attack() -> void:
    get_animation_player().clear_queue()
    for hitbox in _hitboxes.get_children():
        assert(hitbox.get_child_count() == 1)
        var collision_shape: CollisionShape2D = hitbox.get_child(0)
        collision_shape.set_deferred('disabled', true)

func get_health() -> Health:
    return _health

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_camera() -> Camera2D:
    return _camera

func get_wall_slide_trail() -> Particles2D:
    return _wall_slide_trail_effect

func get_grapple_rope() -> Line2D:
    return _grapple_rope

func get_grapple_hook() -> Sprite:
    return _grapple_hook

func get_direction() -> int:
    return -1 if _sprite.flip_h else 1

func set_direction(direction: int) -> void:
    # Flip player sprite.
    _sprite.flip_h = (direction == -1)

    # Flip wall detector raycasts.
    if direction in [-1, 1]:
        _wall_proximity_detector.set_direction(direction)

    # Flip emission direction of dash puff.
    var dash_puff_speed := abs(_dash_puff.process_material.initial_velocity)
    _dash_puff.process_material.initial_velocity = dash_puff_speed * direction

    # Flip all "y-axis mirrored" nodes.
    if direction in [-1, 1]:
        for node in get_tree().get_nodes_in_group('mirror_y_axis'):
            var original_position = _mirror_y_axis_node_original_positions[node]
            node.position.x = original_position.x * direction

func set_nearby_sign(new_sign: Area2D) -> void:
    _nearby_sign = new_sign
func get_nearby_sign() -> Area2D:
    return _nearby_sign

func set_nearby_lamp(new_lamp: Area2D) -> void:
    _nearby_lamp = new_lamp
func get_nearby_lamp() -> Area2D:
    return _nearby_lamp

func set_hazard_checkpoint(hazard_checkpoint: Area2D) -> void:
    _current_hazard_checkpoint = hazard_checkpoint
func get_hazard_checkpoint() -> Area2D:
    return _current_hazard_checkpoint

func get_center() -> Vector2:
    return self.global_position + Vector2(0, -8)

func get_jump_manager() -> JumpManager:
    return _jump_manager

func get_dash_manager() -> DashManager:
    return _dash_manager

# Pause/resume processing for player node specifically. Used during room
# transitions.
func pause() -> void:
    set_physics_process(false)
    set_process_unhandled_input(false)

    for animation in get_animation_player().get_queue():
        _animation_queue.append(animation)
    get_animation_player().stop(false)

    _invincibility_flash_manager.pause_timer()

    _dash_manager.get_dash_cooldown_timer().paused = true

    _dash_duration_timer.paused = true
    _dash_echo_timer.paused = true
    _stagger_duration_timer.paused = true

    _fall_time_stopwatch.pause()
func unpause() -> void:
    set_physics_process(true)
    set_process_unhandled_input(true)

    get_animation_player().play()
    for animation in _animation_queue:
        get_animation_player().queue(animation)
    _animation_queue.clear()

    _invincibility_flash_manager.resume_timer()

    _dash_manager.get_dash_cooldown_timer().paused = false

    _dash_duration_timer.paused = false
    _dash_echo_timer.paused = false
    _stagger_duration_timer.paused = false

    _fall_time_stopwatch.resume()

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

    # Check for overlapping hazard bodies. Some hazards may be StaticBody2Ds
    # instead of Area2Ds.
    for hitbox in _hurtbox.get_overlapping_bodies():
        if Collision.in_layer(hitbox, 'hazards'):
            # Take damage and stagger when hit.
            var damage_taken := player_health.take_damage(1)
            if damage_taken:
                player_health.set_status(Health.Status.INVINCIBLE)
                _invincibility_flash_manager.start_flashing()
                change_state({'new_state': State.HAZARD_HIT})
                emit_signal('player_hit_hazard')

    # Check for overlapping enemy hitbox and hazard areas.
    for hitbox in _hurtbox.get_overlapping_areas():
        if Collision.in_layers(hitbox, ['hazards', 'enemy_hitbox']):
            # Take damage and stagger when hit.
            var damage_taken := player_health.take_damage(1)
            if damage_taken:
                player_health.set_status(Health.Status.INVINCIBLE)
                _invincibility_flash_manager.start_flashing()

                if Collision.in_layer(hitbox, 'hazards'):
                    change_state({'new_state': State.HAZARD_HIT})
                    emit_signal('player_hit_hazard')
                elif Collision.in_layer(hitbox, 'enemy_hitbox'):
                    Rumble.start(Rumble.Type.WEAK, 0.15)
                    Screenshake.start(
                        Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)
                    change_state({
                        'new_state': State.STAGGER,
                        'direction_from_hit': Util.direction(hitbox, self)
                    })

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

    Rumble.start(Rumble.Type.WEAK, 0.10)

    # TODO: This is kind of hacky, find a way around this.
    enemy_hurtbox.get_parent().take_hit(1, self)
