extends KinematicBody2D
class_name Buddy

enum State {
    NO_CHANGE,
    IDLE,
}

onready var STATES := {
    State.IDLE: $States/Idle,
}

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _readable_object: ReadableObject = $ReadableObject

var _current_state: Node = null
var _current_state_enum: int = -1

func _ready() -> void:
    _current_state_enum = State.IDLE
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_readable_object() -> ReadableObject:
    return _readable_object

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
