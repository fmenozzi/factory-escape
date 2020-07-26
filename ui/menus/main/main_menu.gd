extends 'res://ui/menus/menu.gd'

onready var _start: Button = $Start
onready var _options: Button = $Options
onready var _quit: Button = $Quit

func _ready() -> void:
    set_input_enabled(true)

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    match previous_menu:
        Menu.Menus.SAVE_SLOTS:
            _start.grab_focus()
        Menu.Menus.OPTIONS:
            _options.grab_focus()
        Menu.Menus.QUIT:
            _quit.grab_focus()
        _:
            _start.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func set_input_enabled(enabled: bool) -> void:
    _set_focus_enabled(enabled)

    if enabled:
        _start.connect('pressed', self, '_on_start_pressed')
        _options.connect('pressed', self, '_on_options_pressed')
        _quit.connect('pressed', self, '_on_quit_pressed')
    else:
        _start.disconnect('pressed', self, '_on_start_pressed')
        _options.disconnect('pressed', self, '_on_options_pressed')
        _quit.disconnect('pressed', self, '_on_quit_pressed')

func _set_focus_enabled(enabled: bool) -> void:
    if enabled:
        _start.focus_mode = Control.FOCUS_ALL
        _options.focus_mode = Control.FOCUS_ALL
        _quit.focus_mode = Control.FOCUS_ALL
    else:
        _start.focus_mode = Control.FOCUS_NONE
        _options.focus_mode = Control.FOCUS_NONE
        _quit.focus_mode = Control.FOCUS_NONE

func _on_start_pressed() -> void:
    advance_to_menu(Menu.Menus.SAVE_SLOTS)

func _on_options_pressed() -> void:
    advance_to_menu(Menu.Menus.OPTIONS)

func _on_quit_pressed() -> void:
    advance_to_menu(Menu.Menus.QUIT)
