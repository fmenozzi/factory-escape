extends Node2D
class_name ClosingDoorWithSwitch

onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _switch: Switch = $Switch

func _ready() -> void:
    _closing_door.set_closed()

    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func _on_switch_pressed() -> void:
    _closing_door.open()

func pause() -> void:
    pass

func resume() -> void:
    pass

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass
