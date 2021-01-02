extends 'res://ui/menus/menu.gd'

onready var _error_code_label: Label = $ErrorCode
onready var _error_message_label: Label = $ErrorMessage

onready var _back: Button = $Back

func _ready() -> void:
    _back.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    assert('error' in metadata)
    assert('error_msg' in metadata)

    _error_code_label.text = 'Error Code: %d' % metadata['error']
    _error_message_label.text = metadata['error_msg']

    _back.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:

    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_back_pressed() -> void:
    go_to_previous_menu()
