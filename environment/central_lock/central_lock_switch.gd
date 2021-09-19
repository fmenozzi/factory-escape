extends Node2D
class_name CentralLockSwitch

signal unlocked(sector_number)

export(int, 1, 4) var sector_number := 1

onready var _switch: Switch = $Switch

func _ready() -> void:
    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func deactivate() -> void:
    _switch.reset_state_to(Switch.State.PRESSED)

func _on_switch_pressed() -> void:
    emit_signal('unlocked', sector_number)
