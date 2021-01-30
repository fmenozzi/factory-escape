extends 'res://ui/menus/menu.gd'

signal quit_to_main_menu_requested
signal quit_to_desktop_requested

onready var _quit_to_main_menu: Button = $QuitToMainMenu
onready var _quit_to_desktop: Button = $QuitToDesktop
onready var _no: Button = $No

onready var _focusable_nodes := [
    _quit_to_main_menu,
    _quit_to_desktop,
    _no,
]

func _ready() -> void:
    _quit_to_main_menu.connect('pressed', self, '_on_quit_to_main_menu_pressed')
    _quit_to_desktop.connect('pressed', self, '_on_quit_to_desktop_pressed')
    _no.connect('pressed', self, '_on_no_pressed')

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_no)

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    if Controls.get_mode() == Controls.Mode.CONTROLLER:
        get_default_focusable_node().grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func set_input_enabled(enabled: bool) -> void:
    _set_focus_enabled(enabled)

    if enabled:
        _quit_to_main_menu.connect('pressed', self, '_on_quit_to_main_menu_pressed')
        _quit_to_desktop.connect('pressed', self, '_on_quit_to_desktop_pressed')
        _no.connect('pressed', self, '_on_no_pressed')
    else:
        _quit_to_main_menu.disconnect('pressed', self, '_on_quit_to_main_menu_pressed')
        _quit_to_desktop.disconnect('pressed', self, '_on_quit_to_desktop_pressed')
        _no.disconnect('pressed', self, '_on_no_pressed')

func _set_focus_enabled(enabled: bool) -> void:
    if enabled:
        _quit_to_main_menu.focus_mode = Control.FOCUS_ALL
        _quit_to_desktop.focus_mode = Control.FOCUS_ALL
        _no.focus_mode = Control.FOCUS_ALL
    else:
        _quit_to_main_menu.focus_mode = Control.FOCUS_NONE
        _quit_to_desktop.focus_mode = Control.FOCUS_NONE
        _no.focus_mode = Control.FOCUS_NONE

func _on_quit_to_main_menu_pressed() -> void:
    emit_signal('quit_to_main_menu_requested')

func _on_quit_to_desktop_pressed() -> void:
    emit_signal('quit_to_desktop_requested')

func _on_no_pressed() -> void:
    go_to_previous_menu()
