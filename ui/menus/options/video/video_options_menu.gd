extends 'res://ui/menus/menu.gd'

onready var _vsync: CheckBox = $VSync
onready var _fullscreen: CheckBox = $Fullscreen
onready var _back_button: Button = $Back

func _ready() -> void:
    _vsync.connect('pressed', self, '_on_vsync_pressed')
    _fullscreen.connect('pressed', self, '_on_fullscreen_pressed')

    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    _vsync.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_vsync_pressed() -> void:
    # TODO: Save this somewhere persistent as well.
    OS.set_use_vsync(_vsync.is_pressed())

func _on_fullscreen_pressed() -> void:
    # TODO: Save this somewhere persistent as well.
    OS.set_window_fullscreen(_fullscreen.is_pressed())

func _on_back_pressed() -> void:
    go_to_previous_menu()
