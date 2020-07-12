extends 'res://ui/menus/menu.gd'

onready var _jump_remap_button: Button = $JumpRemapContainer/KeyboardRemapButton

onready var _back_button: Button = $Back

var _input_enabled := true

func _ready() -> void:
    for remap_button in get_tree().get_nodes_in_group('keyboard_remap_button'):
        remap_button.connect('remap_started', self, '_set_input_enabled', [false])
        remap_button.connect('remap_finished', self, '_set_input_enabled', [true])

    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    _jump_remap_button.grab_focus()
    _set_input_enabled(true)

    self.visible = true

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if not _input_enabled:
        return

    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled

func _on_back_pressed() -> void:
    go_to_previous_menu()
