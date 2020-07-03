extends 'res://ui/menus/menu.gd'

onready var _quit_to_main_menu: Button = $QuitToMainMenu
onready var _quit_to_desktop: Button = $QuitToDesktop
onready var _no: Button = $No

func _ready() -> void:
    _quit_to_main_menu.connect('pressed', self, '_on_quit_to_main_menu_pressed')
    _quit_to_desktop.connect('pressed', self, '_on_quit_to_desktop_pressed')
    _no.connect('pressed', self, '_on_no_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    _no.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_quit_to_main_menu_pressed() -> void:
    print('quit to main menu not yet implemented')

func _on_quit_to_desktop_pressed() -> void:
    get_tree().quit()

func _on_no_pressed() -> void:
    go_to_previous_menu()
