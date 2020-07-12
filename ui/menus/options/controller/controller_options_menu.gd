extends 'res://ui/menus/menu.gd'

onready var _jump_remap_button: Button = $JumpRemapContainer/ControllerRemapButton

onready var _back_button: Button = $Back

func _ready() -> void:
    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    _jump_remap_button.grab_focus()

    self.visible = true

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_back_pressed() -> void:
    go_to_previous_menu()
