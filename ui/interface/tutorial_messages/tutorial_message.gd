extends Control
class_name TutorialMessage

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

func _ready() -> void:
    hide()

    Controls.connect('mode_changed', self, '_on_control_mode_changed')

func set_control_message(
    controller_button_texture: Texture,
    keyboard_button_label: String,
    control_label: String
) -> void:
    _set_message_mode(MessageMode.CONTROL)

    _controller_button_texture.texture = controller_button_texture
    _keyboard_button_label.text = keyboard_button_label
    _control_label.text = control_label

func set_non_control_message(message: String) -> void:
    _set_message_mode(MessageMode.NON_CONTROL)

    _non_control_message_label.text = message

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

func _on_control_mode_changed(new_control_mode: int) -> void:
    assert(new_control_mode in [Controls.Mode.CONTROLLER, Controls.Mode.KEYBOARD])

    match new_control_mode:
        Controls.Mode.CONTROLLER:
            _controller_button_texture.show()
            _keyboard_button_label.hide()

        Controls.Mode.KEYBOARD:
            _controller_button_texture.hide()
            _keyboard_button_label.show()
