extends Node2D
class_name ClosingDoorWithSwitchSectorFive

onready var _closing_door: StaticBody2D = $ClosingDoorSectorFive
onready var _switch: Switch = $SwitchSectorFive
onready var _save_manager: ClosingDoorWithSwitchSectorFiveSaveManager = $SaveManager

func _ready() -> void:
    _closing_door.set_closed()

    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func _on_switch_pressed() -> void:
    _closing_door.open()
    _save_manager.is_open = true
    Screenshake.start(
        Screenshake.Duration.LONG, Screenshake.Amplitude.VERY_SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.5, Rumble.Priority.HIGH)

func pause() -> void:
    pass

func resume() -> void:
    pass

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass
