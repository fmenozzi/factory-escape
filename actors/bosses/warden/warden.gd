extends KinematicBody2D
class_name Warden

signal intro_sequence_finished

enum State {
    NO_CHANGE,
    NEXT_STATE_IN_SEQUENCE,
    INTRO_SEQUENCE,
    IDLE,
    BACKSTEP,
    LEAP,
    CHARGE,
    CHARGE_RECOVER_SLIDE,
    CHARGE_IMPACT,
}

export(Util.Direction) var initial_direction := Util.Direction.RIGHT
export(State) var initial_state := State.INTRO_SEQUENCE

onready var STATES := {
    State.INTRO_SEQUENCE:       $States/IntroSequence,
    State.IDLE:                 $States/Idle,
    State.BACKSTEP:             $States/Backstep,
    State.LEAP:                 $States/Leap,
    State.CHARGE:               $States/Charge,
    State.CHARGE_RECOVER_SLIDE: $States/ChargeRecoverSlide,
    State.CHARGE_IMPACT:        $States/ChargeImpact,
}

var direction: int

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _physics_manager: WardenPhysicsManager = $PhysicsManager
onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    set_direction(initial_direction)

    _current_state_enum = initial_state
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

    _health.connect('died', self, '_die')

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()

func get_physics_manager() -> WardenPhysicsManager:
    return _physics_manager

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func lamp_reset() -> void:
    queue_free()

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

func _die() -> void:
    pass
