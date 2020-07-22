extends KinematicBody2D
class_name Player

signal player_state_changed(old_state_enum, new_state_enum)
signal player_hit_hazard

# The possible states that the player can be in. The NO_CHANGE state is reserved
# for states indicating that the current state should not be changed and does
# not itself constitute a valid player state.
enum State {
    NO_CHANGE,
    NEXT_STATE_IN_SEQUENCE,
    IDLE,
    WALK,
    JUMP,
    DOUBLE_JUMP,
    FALL,
    DASH,
    WALL_SLIDE,
    WALL_JUMP,
    ATTACK,
    ATTACK_UP,
    GRAPPLE,
    STAGGER,
    HAZARD_HIT,
    HAZARD_RECOVER,
    LIGHT_LAMP,
    REST_AT_LAMP,
    READ_SIGN,
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
    State.ATTACK:         $States/Attack,
    State.ATTACK_UP:      $States/AttackUp,
    State.GRAPPLE:        $States/Grapple,
    State.STAGGER:        $States/Stagger,
    State.HAZARD_HIT:     $States/HazardHit,
    State.HAZARD_RECOVER: $States/HazardRecover,
    State.LIGHT_LAMP:     $States/LightLamp,
    State.REST_AT_LAMP:   $States/RestAtLamp,
    State.READ_SIGN:      $States/ReadSign,
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
onready var _dash_echoes: Particles2D = $DashEchoes
onready var _hit_effect: PlayerHitEffect = $PlayerHitEffect

onready var _grapple_rope: Line2D = $GrappleRope
onready var _grapple_hook: Sprite = $GrappleHook
onready var _grapple_line_of_sight: RayCast2D = $GrappleLineOfSight

onready var _health: Health = $Health
onready var _hitboxes: Node2D = $Hitboxes
onready var _hurtbox: Area2D = $Hurtbox

onready var _invincibility_flash_manager_hazard_hit: Node = $States/HazardHit/FlashManager
onready var _invincibility_flash_manager_enemy_hit: Node = $States/Stagger/Hit/FlashManager

onready var _physics_manager: GroundedPhysicsManager = $PhysicsManager

onready var _dash_duration_timer: Timer = $States/Dash/DashDurationTimer

onready var _knockback_duration_timer: Timer = $States/Stagger/Knockback/KnockbackDurationTimer

onready var _fall_time_stopwatch: Stopwatch = $States/Fall/FallTimeStopwatch

onready var _jump_manager: JumpManager = $JumpManager
onready var _dash_manager: DashManager = $DashManager
onready var _attack_manager: AttackManager = $Attackmanager

# The grapple point to be used the next time the player presses the grapple
# button. This is updated on every frame based on several candidacy rules. If
# there are no valid grapple points for the player on a given frame, this is set
# to null and grappling has no effect.
var _next_grapple_point: GrapplePoint = null

var _nearby_readable_object = null
var _nearby_lamp = null

var _current_hazard_checkpoint: Area2D = null

var last_saved_global_position: Vector2 = Vector2(50, 144)
var last_saved_direction_to_lamp: int = Util.Direction.RIGHT

# Keep track of the current room the player is in, as well as the previous room
# the player was in, to assist in room transitions.
var prev_room = null
var curr_room = null

var use_attack_1 := true

func _ready() -> void:
    # Begin in fall state
    current_state_enum = State.FALL
    current_state = STATES[current_state_enum]
    change_state({'new_state': State.FALL})

    # Save the current positions of all "y-axis mirrored" nodes so that they can
    # all be mirrored at once when the player changes direction.
    for node in get_tree().get_nodes_in_group('mirror_y_axis'):
        _mirror_y_axis_node_original_positions[node] = node.get_position()

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

func get_save_data() -> Array:
    return ['player', {
        'global_position_x': last_saved_global_position.x,
        'global_position_y': last_saved_global_position.y,
        'direction_to_lamp': last_saved_direction_to_lamp,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not 'player' in all_save_data:
        return

    var player_save_data: Dictionary = all_save_data['player']
    assert('global_position_x' in player_save_data)
    assert('global_position_y' in player_save_data)
    assert('direction_to_lamp' in player_save_data)

    last_saved_global_position.x = player_save_data['global_position_x']
    last_saved_global_position.y = player_save_data['global_position_y']
    last_saved_direction_to_lamp = player_save_data['direction_to_lamp']

    global_position = last_saved_global_position

    set_direction(last_saved_direction_to_lamp)

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

func emit_dash_effects() -> void:
    _dash_puff.restart()
    _dash_echoes.restart()

func start_attack(attack_animation_name: String = 'attack_1') -> void:
    _enemies_hit.clear()
    get_animation_player().play(attack_animation_name)

# Flush animation queue so that we can cancel attack animations cleanly.
func stop_attack() -> void:
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

func get_hit_effect() -> PlayerHitEffect:
    return _hit_effect

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

    # Use appropriate texture for dash echoes.
    match direction:
        Util.Direction.LEFT:
            _dash_echoes.texture = Preloads.DashEchoLeft
        Util.Direction.RIGHT:
            _dash_echoes.texture = Preloads.DashEchoRight

    # Flip all "y-axis mirrored" nodes.
    if direction in [-1, 1]:
        for node in get_tree().get_nodes_in_group('mirror_y_axis'):
            var original_position = _mirror_y_axis_node_original_positions[node]
            node.position.x = original_position.x * direction

func set_nearby_readable_object(new_readable_object: Node2D) -> void:
    _nearby_readable_object = new_readable_object
func get_nearby_readable_object() -> Node2D:
    return _nearby_readable_object

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

func get_attack_manager() -> AttackManager:
    return _attack_manager

# Pause/resume processing for player node specifically. Used during room
# transitions.
func pause() -> void:
    set_physics_process(false)
    set_process_unhandled_input(false)

    for animation in get_animation_player().get_queue():
        _animation_queue.append(animation)
    get_animation_player().stop(false)

    _invincibility_flash_manager_hazard_hit.pause_timer()
    _invincibility_flash_manager_enemy_hit.pause_timer()

    _dash_manager.get_dash_cooldown_timer().paused = true

    _dash_puff.speed_scale = 0
    _dash_echoes.speed_scale = 0

    _dash_duration_timer.paused = true
    _knockback_duration_timer.paused = true

    _fall_time_stopwatch.pause()
func unpause() -> void:
    set_physics_process(true)
    set_process_unhandled_input(true)

    get_animation_player().play()
    for animation in _animation_queue:
        get_animation_player().queue(animation)
    _animation_queue.clear()

    _invincibility_flash_manager_hazard_hit.resume_timer()
    _invincibility_flash_manager_enemy_hit.resume_timer()

    _dash_manager.get_dash_cooldown_timer().paused = false

    _dash_puff.speed_scale = 1
    _dash_echoes.speed_scale = 1

    _dash_duration_timer.paused = false
    _knockback_duration_timer.paused = false

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
            change_state({'new_state': State.HAZARD_HIT})
            emit_signal('player_hit_hazard')

    # Check for overlapping hazard bodies. Some hazards may be StaticBody2Ds
    # instead of Area2Ds.
    for hitbox in _hurtbox.get_overlapping_bodies():
        if Collision.in_layer(hitbox, 'hazards'):
            # Take damage and stagger when hit.
            var damage_taken := player_health.take_damage(1)
            if damage_taken:
                change_state({'new_state': State.HAZARD_HIT})
                emit_signal('player_hit_hazard')

    # Check for overlapping enemy hitbox and hazard areas.
    for hitbox in _hurtbox.get_overlapping_areas():
        if Collision.in_layers(hitbox, ['hazards', 'enemy_hitbox']):
            # Take damage and stagger when hit.
            var damage_taken := player_health.take_damage(1)
            if damage_taken:
                if Collision.in_layer(hitbox, 'hazards'):
                    change_state({'new_state': State.HAZARD_HIT})
                    emit_signal('player_hit_hazard')
                elif Collision.in_layer(hitbox, 'enemy_hitbox'):
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
    Screenshake.start(
        Screenshake.Duration.VERY_SHORT, Screenshake.Amplitude.VERY_SMALL)

    var enemy = enemy_hurtbox.get_parent()

    var enemy_hit_effect: EnemyHitEffect = Preloads.EnemyHitEffect.instance()
    get_parent().get_node('TemporaryNodes').add_child(enemy_hit_effect)
    enemy_hit_effect.global_position = enemy.global_position
    if current_state() == State.ATTACK_UP:
        enemy_hit_effect.rotation_degrees = -90
    else:
        enemy_hit_effect.position.y -= 8
        enemy_hit_effect.scale.x = Util.direction(self, enemy)

    # TODO: This is kind of hacky, find a way around this.
    enemy.take_hit(1, self)
