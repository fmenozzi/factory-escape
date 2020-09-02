extends Control

# Signal that returns a boolean representing whether the player selected "Yes"
# in the Yes/No dialog.
signal selection_made(yes_selected)

onready var _message: Control = $Message
onready var _message_label: RichTextLabel = $Message/RichTextLabel

onready var _confirmation_widget: Control = $ConfirmationWidget
onready var _yes: Button = $ConfirmationWidget/HBoxContainer/Yes
onready var _no: Button = $ConfirmationWidget/HBoxContainer/No

func _ready() -> void:
    set_process_unhandled_input(false)

    _yes.connect('pressed', self, '_on_yes_pressed')
    _no.connect('pressed', self, '_on_no_pressed')

func show_dialog(msg: String) -> void:
    _message_label.text = msg

    _no.grab_focus()

    _message.show()
    _confirmation_widget.show()

    set_process_unhandled_input(true)

func hide_dialog() -> void:
    _yes.release_focus()
    _no.release_focus()

    _message.hide()
    _confirmation_widget.hide()

func _on_yes_pressed() -> void:
    hide_dialog()

    emit_signal('selection_made', true)

func _on_no_pressed() -> void:
    hide_dialog()

    emit_signal('selection_made', false)
