extends KinematicBody2D
class_name LeapingFailure

export(Util.Direction) var direction := Util.Direction.RIGHT

const SPEED := 0.5 * Util.TILE_SIZE

enum State {
    NO_CHANGE,
    WALK,
    FALL,
}

onready var STATES := {
    State.WALK: $States/Walk,
    State.FALL: $States/Fall,
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _sprite: Sprite = $Sprite
onready var _dust_puff: Particles2D = $DustPuff

func _ready() -> void:
    set_direction(direction)

    _current_state_enum = State.FALL
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func emit_dust_puff() -> void:
    _dust_puff.restart()

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
