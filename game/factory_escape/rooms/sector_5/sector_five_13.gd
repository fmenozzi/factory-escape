extends Room

onready var _closing_door_left: StaticBody2D = $ClosingDoorLeft
onready var _closing_door_right: StaticBody2D = $ClosingDoorRight
onready var _switch: Switch = $SwitchSectorFive
onready var _one_off_dialog_box: Control = get_node('../../../../Layers/DialogBoxLayer/OneOffDialogBox')

var _dialog = [
    '[center]WARNING: Main power systems overloaded\nBeginning self-destruct in [color=#fd9359]3[/color]...[/center]',
    '[center]WARNING: Main power systems overloaded\nBeginning self-destruct in [color=#fd9359]2[/color]...[/center]',
    '[center]WARNING: Main power systems overloaded\nBeginning self-destruct in [color=#fd9359]1[/color]...[/center]',
]

func _ready() -> void:
    lamp_reset()

    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func lamp_reset() -> void:
    _closing_door_left.set_opened()
    _closing_door_right.set_closed()
    _switch.reset_state_to(Switch.State.UNPRESSED)

func _on_switch_pressed() -> void:
    # Start escape sequence dialog. Wait a bit after dialog finishes before
    # hiding it and starting escape sequence.
    _one_off_dialog_box.start(_dialog[0])
    yield(_one_off_dialog_box, 'dialog_finished')
    yield(get_tree().create_timer(1), 'timeout')
    _one_off_dialog_box._label.bbcode_text = _dialog[1]
    yield(get_tree().create_timer(1), 'timeout')
    _one_off_dialog_box._label.bbcode_text = _dialog[2]
    yield(get_tree().create_timer(1), 'timeout')
    _one_off_dialog_box.stop()

    # Start escape sequence.
    _closing_door_left.close()
    _closing_door_right.open()
    EscapeSequenceEffects.start()

    # Resume player processing.
    var player: Player = Util.get_player()
    player.set_process_unhandled_input(true)
    player.set_physics_process(true)
