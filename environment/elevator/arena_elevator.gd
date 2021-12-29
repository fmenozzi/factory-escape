extends Node2D

export(Switch.State) var switch_state: int = Switch.State.UNPRESSED

onready var _switch: Switch = $Platform/Switch

func _ready() -> void:
    _switch.reset_state_to(switch_state)
    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func _on_switch_pressed() -> void:
    pass
