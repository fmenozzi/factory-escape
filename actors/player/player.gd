extends KinematicBody2D
class_name Player

signal player_state_changed(old_state_enum, new_state_enum)
signal player_hit_by_enemy
signal player_hit_hazard
signal player_healed
signal player_reached_walk_to_point

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
    LOOK_DOWN,
    LOOK_UP,
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
    SLEEP,
    READ_SIGN,
    TAKE_HEALTH_PACK,
    ACTIVATE_SWITCH,
    HARD_LANDING,
    HEAL,
    DIE,
    SUSPENDED,
    INTRO_FALL,
    CENTRAL_HUB_FALL,
}

# Maps State enum to corresponding state scripts.
onready var STATES = {
    State.IDLE:             $States/Idle,
    State.WALK:             $States/Walk,
    State.JUMP:             $States/Jump,
    State.DOUBLE_JUMP:      $States/DoubleJump,
    State.FALL:             $States/Fall,
    State.DASH:             $States/Dash,
    State.LOOK_DOWN:        $States/LookDown,
    State.LOOK_UP:          $States/LookUp,
    State.WALL_SLIDE:       $States/WallSlide,
    State.WALL_JUMP:        $States/WallJump,
    State.ATTACK:           $States/Attack,
    State.ATTACK_UP:        $States/AttackUp,
    State.GRAPPLE:          $States/Grapple,
    State.STAGGER:          $States/Stagger,
    State.HAZARD_HIT:       $States/HazardHit,
    State.HAZARD_RECOVER:   $States/HazardRecover,
    State.LIGHT_LAMP:       $States/LightLamp,
    State.REST_AT_LAMP:     $States/RestAtLamp,
    State.SLEEP:            $States/Sleep,
    State.READ_SIGN:        $States/ReadSign,
    State.TAKE_HEALTH_PACK: $States/TakeHealthPack,
    State.ACTIVATE_SWITCH:  $States/ActivateSwitch,
    State.HARD_LANDING:     $States/HardLanding,
    State.HEAL:             $States/Heal,
    State.DIE:              $States/Die,
    State.SUSPENDED:        $States/Suspended,
    State.INTRO_FALL:       $States/IntroFall,
    State.CENTRAL_HUB_FALL: $States/CentralHubFall,
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

onready var _floor_proximity_detector: RayCast2D = $FloorProximityDetector

onready var _wall_slide_trail_effect: Particles2D = $WallSlideTrail
onready var _dash_puff: Particles2D = $DashPuff
onready var _dash_echoes: Particles2D = $DashEchoes
onready var _hit_effect: PlayerHitEffect = $PlayerHitEffect

onready var _health: Health = $Health
onready var _hitboxes: Node2D = $Hitboxes
onready var _side_attack_hitbox: Area2D = $Hitboxes/SideAttack
onready var _up_attack_hitbox: Area2D = $Hitboxes/UpAttack
onready var _hurtbox: Area2D = $Hurtbox

onready var _attack_state: Node = $States/Attack
onready var _attack_up_state: Node = $States/AttackUp

onready var _invincibility_flash_manager_hazard_hit: Node = $States/HazardHit/FlashManager
onready var _invincibility_flash_manager_enemy_hit: Node = $States/Stagger/Hit/FlashManager

onready var _physics_manager: GroundedPhysicsManager = $PhysicsManager
onready var _health_pack_manager: HealthPackManager = $HealthPackManager
onready var _sound_manager: PlayerSoundManager = $PlayerSoundManager

onready var _dash_duration_timer: Timer = $States/Dash/DashDurationTimer

onready var _knockback_duration_timer: Timer = $States/Stagger/Knockback/KnockbackDurationTimer

onready var _fall_time_stopwatch: Stopwatch = $States/Fall/FallTimeStopwatch

onready var _jump_manager: JumpManager = $JumpManager
onready var _dash_manager: DashManager = $DashManager
onready var _grapple_manager: GrappleManager = $GrappleManager
onready var _wall_jump_manager: WallJumpManager = $WallJumpManager
onready var _attack_manager: AttackManager = $Attackmanager

var _nearby_readable_object = null
var _nearby_lamp = null
var _nearby_switch = null

var _current_hazard_checkpoint: Area2D = null

# Keep track of the current room the player is in, as well as the previous room
# the player was in, to assist in room transitions.
var prev_room = null
var curr_room = null

onready var save_manager: PlayerSaveManager = $SaveManager

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

    _side_attack_hitbox.connect('area_entered', _attack_state, '_on_attack_connected')
    _up_attack_hitbox.connect('area_entered', _attack_up_state, '_on_attack_connected')

    _hurtbox.connect('area_entered', self, '_on_hazard_area_hit')
    _hurtbox.connect('body_entered', self, '_on_hazard_body_hit')

func _unhandled_input(event: InputEvent) -> void:
    var new_state_dict = current_state.handle_input(self, event)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        change_state(new_state_dict)

func _physics_process(delta: float) -> void:
    _grapple_manager.update_next_grapple_point(self, curr_room)

    _check_for_hits()

    var new_state_dict = current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        change_state(new_state_dict)

func lamp_reset() -> void:
    get_health().heal_to_full()

    global_position = save_manager.last_saved_global_position
    set_direction(save_manager.last_saved_direction_to_lamp)

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

func get_health_pack_manager() -> HealthPackManager:
    return _health_pack_manager

func get_sound_manager() -> PlayerSoundManager:
    return _sound_manager

func get_hazard_hit_invincibility_flash_manager() -> Node:
    return _invincibility_flash_manager_hazard_hit

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

func emit_dust_puff() -> void:
    Effects.spawn_dust_puff_at(self.global_position)

func emit_dash_effects() -> void:
    _dash_puff.restart()
    _dash_echoes.restart()

func start_attack(attack_animation_name: String = 'attack_1') -> void:
    _enemies_hit.clear()
    get_animation_player().play(attack_animation_name)

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

func get_direction() -> int:
    return -1 if _sprite.flip_h else 1

func set_direction(direction: int) -> void:
    # Flip player sprite.
    _sprite.flip_h = (direction == -1)

    # Flip wall detector raycasts.
    if direction in [-1, 1]:
        _wall_jump_manager.get_wall_proximity_detector().set_direction(direction)

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

func set_nearby_switch(new_switch: Node2D) -> void:
    _nearby_switch = new_switch
func get_nearby_switch() -> Node2D:
    return _nearby_switch

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

func get_grapple_manager() -> GrappleManager:
    return _grapple_manager

func get_wall_jump_manager() -> WallJumpManager:
    return _wall_jump_manager

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
            # Only initiate hazard hit if the player hasn't died as a result of
            # being crushed (otherwise, let the death transition play out).
            if player_health.get_current_health() != 0:
                change_state({'new_state': State.HAZARD_HIT})
                emit_signal('player_hit_hazard')

    # Check for overlapping enemy hitbox and hazard areas.
    for hitbox in _hurtbox.get_overlapping_areas():
        if Collision.in_layer(hitbox, 'enemy_hitbox'):
            # Take damage and stagger when hit, unless the hit resulted in the
            # player's death, in which case let the death transition play out.
            var damage_taken := player_health.take_damage(1)
            if damage_taken:
                var health_after_hit := player_health.get_current_health()
                emit_signal('player_hit_by_enemy', health_after_hit)
                if health_after_hit != 0:
                    if Collision.in_layer(hitbox, 'hazards'):
                        change_state({'new_state': State.HAZARD_HIT})
                        emit_signal('player_hit_hazard')
                    elif Collision.in_layer(hitbox, 'enemy_hitbox'):
                        change_state({
                            'new_state': State.STAGGER,
                            'direction_from_hit': Util.direction(hitbox, self)
                        })
                else:
                    # Play the appropriate sound effect even if the hit results
                    # in death.
                    if Collision.in_layer(hitbox, 'hazards'):
                        get_sound_manager().play(PlayerSoundManager.Sounds.HAZARD_HIT)
                    elif Collision.in_layer(hitbox, 'enemy_hitbox'):
                        get_sound_manager().play(PlayerSoundManager.Sounds.HIT)

func _check_for_hazard_hit(hitbox_area_or_body) -> void:
    if not Collision.in_layer(hitbox_area_or_body, 'hazards'):
        return

    var player_health := get_health()

    # Take damage and stagger when hit, unless the hit resulted in the player's
    # death, in which case let the death transition play out.
    var damage_taken := player_health.take_damage(1)
    if damage_taken:
        if player_health.get_current_health() != 0:
            change_state({'new_state': State.HAZARD_HIT})
            emit_signal('player_hit_hazard')
        else:
            # Play the sound effect even if the hazard hit results in death.
            get_sound_manager().play(PlayerSoundManager.Sounds.HAZARD_HIT)

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

func _on_hazard_area_hit(hitbox: Area2D) -> void:
    _check_for_hazard_hit(hitbox)

func _on_hazard_body_hit(hitbox: Node) -> void:
    _check_for_hazard_hit(hitbox)

func _on_landed_on_spring_board() -> void:
    change_state({'new_state': State.JUMP})
