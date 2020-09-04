extends Node2D
class_name JumpManager

enum State {
    NOT_JUMPED,
    JUMPED,
    DOUBLE_JUMPED,
}
var _state: int = State.NOT_JUMPED

var _has_double_jump: bool

onready var _jump_buffer_raycast: RayCast2D = $JumpBufferRaycast

func _ready() -> void:
    _has_double_jump = true

func can_jump() -> bool:
    assert(_state in [State.NOT_JUMPED, State.JUMPED, State.DOUBLE_JUMPED])

    match _state:
        State.NOT_JUMPED:
            # If we haven't jumped, we can jump.
            return true

        State.JUMPED:
            # If we've already jumped, we can only jump again if we have the
            # double jump.
            return _has_double_jump

        _:
            # If we've already double-jumped, we can't jump anymore.
            return false

func has_double_jump() -> bool:
    return _has_double_jump

func consume_jump() -> void:
    assert(_state in [State.NOT_JUMPED, State.JUMPED, State.DOUBLE_JUMPED])

    match _state:
        State.NOT_JUMPED:
            _state = State.JUMPED

        State.JUMPED:
            if _has_double_jump:
                _state = State.DOUBLE_JUMPED


func reset_jump() -> void:
    _state = State.NOT_JUMPED

func get_jump_buffer_raycast() -> RayCast2D:
    return _jump_buffer_raycast
