extends KinematicBody2D
class_name LeapingFailure

enum State {
    NO_CHANGE,
    NEXT_STATE_IN_SEQUENCE,
    EXPAND,
    CONTRACT,
    EXPAND_FAST,
    CONTRACT_FAST,
    PAUSE,
    RETURN_TO_LEDGE,
    ALERTED,
    UNALERTED,
    FALL,
    LEAP,
    DIE,
}

export(Util.Direction) var initial_direction := Util.Direction.RIGHT
export(State) var initial_state := State.CONTRACT

onready var STATES := {
    State.EXPAND:          $States/Expand,
    State.CONTRACT:        $States/Contract,
    State.EXPAND_FAST:     $States/ExpandFast,
    State.CONTRACT_FAST:   $States/ContractFast,
    State.PAUSE:           $States/Pause,
    State.RETURN_TO_LEDGE: $States/ReturnToLedge,
    State.ALERTED:         $States/Alerted,
    State.UNALERTED:       $States/Unalerted,
    State.FALL:            $States/Fall,
    State.LEAP:            $States/Leap,
    State.DIE:             $States/Die,
}

var direction: int

var _initial_global_position: Vector2

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _physics_manager: LeapingFailurePhysicsManager = $PhysicsManager
onready var _aggro_manager: AggroManager = $AggroManager
onready var _pushback_manager: PushbackManager = $PushbackManager
onready var _sound_manager: EnemySoundManager = $EnemySoundManager
onready var _sprite: Sprite = $Sprite
onready var _react_sprite: ReactSprite = $ReactSprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _hurtbox_collision_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
onready var _edge_raycast_left: RayCast2D = $LedgeDetectorRaycasts/Left
onready var _edge_raycast_right: RayCast2D = $LedgeDetectorRaycasts/Right

func _ready() -> void:
    set_direction(initial_direction)

    _initial_global_position = global_position

    _current_state_enum = initial_state
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum, 'aggro': false})

    _react_sprite.change_state(ReactSprite.State.NONE)

    _health.connect('died', self, '_on_died')

    STATES[State.EXPAND].connect(
        'expanded', _sound_manager, 'play', [EnemySoundManager.Sounds.EXPAND_ORGANIC])
    STATES[State.CONTRACT].connect(
        'contracted', _sound_manager, 'play', [EnemySoundManager.Sounds.CONTRACT_ORGANIC])

func _physics_process(delta: float) -> void:
    if _pushback_manager.is_being_pushed_back():
        move(_pushback_manager.get_pushback_velocity())

    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()
    _sound_manager.play(EnemySoundManager.Sounds.ENEMY_HIT_ORGANIC)
    if is_on_floor():
        _pushback_manager.start_pushback(
            player.get_center().direction_to(global_position))

func get_physics_manager() -> LeapingFailurePhysicsManager:
    return _physics_manager

func get_aggro_manager() -> AggroManager:
    return _aggro_manager

func get_sound_manager() -> EnemySoundManager:
    return _sound_manager

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func is_off_ledge() -> bool:
    var off_left := not _edge_raycast_left.is_colliding()
    var off_right := not _edge_raycast_right.is_colliding()

    return (off_left and not off_right) or (off_right and not off_left)

func emit_dust_puff() -> void:
    Effects.spawn_dust_puff_at(global_position)

func get_react_sprite() -> ReactSprite:
    return _react_sprite

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func set_hit_and_hurt_boxes_disabled(disabled: bool) -> void:
    _hitbox_collision_shape.set_deferred('disabled', disabled)
    _hurtbox_collision_shape.set_deferred('disabled', disabled)

func pause() -> void:
    set_physics_process(false)
    _animation_player.stop(false)
    _sound_manager.set_all_muted(true)

func resume() -> void:
    set_physics_process(true)
    _animation_player.play()
    _sound_manager.set_all_muted(false)

    # Don't tween to new volume.
    for visibility_player in _sound_manager.get_all_visibility_players():
        visibility_player.set_state(false)

func room_reset() -> void:
    if _current_state_enum != State.DIE:
        lamp_reset()

func lamp_reset() -> void:
    global_position = _initial_global_position
    set_direction(initial_direction)
    _health.heal_to_full()
    _change_state({'new_state': initial_state})

func is_dead() -> bool:
    return _current_state_enum == State.DIE

func _change_state(new_state_dict: Dictionary) -> void:
    var old_state_enum := _current_state_enum
    var new_state_enum: int = new_state_dict['new_state']

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = old_state_enum

    _current_state.exit(self)
    _current_state_enum = new_state_enum
    _current_state = STATES[new_state_enum]
    _current_state.enter(self, new_state_dict)

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    _change_state({'new_state': State.DIE})
