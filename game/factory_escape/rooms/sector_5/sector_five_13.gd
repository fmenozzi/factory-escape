extends Room

onready var _closing_door_left: StaticBody2D = $ClosingDoorLeft
onready var _closing_door_right: StaticBody2D = $ClosingDoorRight
onready var _switch: Switch = $Switch

func _ready() -> void:
    lamp_reset()

    _switch.connect('switch_press_finished', self, '_start_escape_sequence')

func _start_escape_sequence() -> void:
    _closing_door_left.close()
    _closing_door_right.open()

    EscapeSequenceEffects.start()

func lamp_reset() -> void:
    _closing_door_left.set_opened()
    _closing_door_right.set_closed()
    _switch.reset_state_to(Switch.State.UNPRESSED)
