extends Node

signal mode_changed(new_mode)

enum Mode {
    CONTROLLER,
    KEYBOARD,
}

var _mode: int = Mode.CONTROLLER

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        if _mode == Mode.KEYBOARD:
            _set_mode(Mode.CONTROLLER)

    if event is InputEventKey or event is InputEventMouse:
        if _mode == Mode.CONTROLLER:
            _set_mode(Mode.KEYBOARD)

func _set_mode(new_mode: int) -> void:
    assert(new_mode in [Mode.CONTROLLER, Mode.KEYBOARD])

    _mode = new_mode

    emit_signal('mode_changed', new_mode)
