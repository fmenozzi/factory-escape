extends Room

onready var _closing_door_left: StaticBody2D = $ClosingDoorLeft
onready var _closing_door_right: StaticBody2D = $ClosingDoorRight
onready var _switch: Switch = $SwitchSectorFive
onready var _one_off_dialog_box: Control = get_node('../../../../Layers/DialogBoxLayer/OneOffDialogBox')

func _ready() -> void:
    lamp_reset()

    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func lamp_reset() -> void:
    _closing_door_left.set_opened()
    _closing_door_right.set_closed()
    _switch.reset_state_to(Switch.State.UNPRESSED)

func _center_text(text: String) -> String:
    return '[center]' + text + '[/center]'

func _on_switch_pressed() -> void:
    # Start escape sequence dialog. Wait a bit after dialog finishes before
    # hiding it and starting escape sequence.
    _one_off_dialog_box.start(_center_text('Self-destruct sequence activated\nBeginning power-down...'))
    yield(_one_off_dialog_box, 'dialog_finished')
    yield(get_tree().create_timer(3.0), 'timeout')
    _one_off_dialog_box.stop()

    # Start escape sequence.
    _closing_door_left.close()
    _closing_door_right.open()
    EscapeSequenceEffects.start()

    # Resume player processing.
    var player: Player = Util.get_player()
    player.set_process_unhandled_input(true)
    player.set_physics_process(true)
