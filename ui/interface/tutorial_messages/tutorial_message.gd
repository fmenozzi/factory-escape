extends Control
class_name TutorialMessage

const VISIBLE := Color(1, 1, 1, 1)
const NOT_VISIBLE := Color(1, 1, 1, 0)

enum MessageMode {
    CONTROL,
    NON_CONTROL,
}

var _message_mode: int

onready var _control_message: Control = $ControlMessage
onready var _controller_button_texture: TextureRect = $ControlMessage/ControllerButtonTexture
onready var _keyboard_button_label: Label = $ControlMessage/KeyboardButtonLabel
onready var _control_label: Label = $ControlMessage/Label

onready var _non_control_message: Control = $NonControlMessage
onready var _non_control_message_label: Label = $NonControlMessage/Label

onready var _tween: Tween = $FadeTween

func _ready() -> void:
    self.modulate = NOT_VISIBLE

    for trigger in get_tree().get_nodes_in_group('tutorial_message_triggers'):
        trigger.connect(
            'player_entered_area', self, '_on_player_entered_tutorial_message_area')
        trigger.connect(
            'player_exited_area', self, '_on_player_exited_tutorial_message_area')

    Controls.connect('mode_changed', self, '_on_control_mode_changed')
    Controls.connect('control_remapped', self, '_on_control_remapped')

func _set_message_mode(new_message_mode: int) -> void:
    assert(new_message_mode in [MessageMode.CONTROL, MessageMode.NON_CONTROL])

    _message_mode = new_message_mode

    match _message_mode:
        MessageMode.CONTROL:
            _control_message.show()
            _non_control_message.hide()

        MessageMode.NON_CONTROL:
            _control_message.hide()
            _non_control_message.show()

func _get_controller_button_texture(player_action: String) -> Texture:
    return Controls.get_joypad_texture_for_action(player_action)

func _get_keyboard_button_label(player_action: String) -> String:
    var scancode: int = Controls.get_scancode_for_action(player_action)
    assert(scancode != -1)

    return OS.get_scancode_string(scancode)

func _modulate_visibility(old: Color, new: Color) -> void:
    var prop := 'modulate'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    _tween.stop_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

# Automatically switch between the controller button texture and the keyboard
# button label when the control mode changes.
func _on_control_mode_changed(new_control_mode: int) -> void:
    assert(new_control_mode in [Controls.Mode.CONTROLLER, Controls.Mode.KEYBOARD])

    match new_control_mode:
        Controls.Mode.CONTROLLER:
            _controller_button_texture.show()
            _keyboard_button_label.hide()

        Controls.Mode.KEYBOARD:
            _controller_button_texture.hide()
            _keyboard_button_label.show()

# Automatically change the controller button texture and keyboard button label
# when a control is remapped.
func _on_control_remapped(player_action: String, new_event: InputEvent) -> void:
    _controller_button_texture.texture = _get_controller_button_texture(player_action)
    _keyboard_button_label.text = _get_keyboard_button_label(player_action)

func _on_player_entered_tutorial_message_area(
    message_mode: int,
    message: String,
    player_action: String
) -> void:
    assert(message_mode in [
        MessageMode.CONTROL,
        MessageMode.NON_CONTROL
    ])

    match message_mode:
        MessageMode.CONTROL:
            assert(not player_action.empty())

            _set_message_mode(MessageMode.CONTROL)

            _controller_button_texture.texture = _get_controller_button_texture(player_action)
            _keyboard_button_label.text = _get_keyboard_button_label(player_action)

            _control_label.text = message

        MessageMode.NON_CONTROL:
            _set_message_mode(MessageMode.NON_CONTROL)

            _non_control_message_label.text = message

    _modulate_visibility(self.modulate, VISIBLE)

func _on_player_exited_tutorial_message_area(
    message_mode: int,
    message: String,
    player_action: String
) -> void:
    _modulate_visibility(self.modulate, NOT_VISIBLE)
