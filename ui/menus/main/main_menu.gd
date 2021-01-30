extends 'res://ui/menus/menu.gd'

onready var _start: Button = $Start
onready var _options: Button = $Options
onready var _credits: Button = $Credits
onready var _quit: Button = $Quit

onready var _focusable_nodes := [
    _start,
    _options,
    _credits,
    _quit,
]

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

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    pass

func set_input_enabled(enabled: bool) -> void:
    _set_focus_enabled(enabled)

    if enabled:
        _start.connect('pressed', self, '_on_start_pressed')
        _options.connect('pressed', self, '_on_options_pressed')
        _credits.connect('pressed', self, '_on_credits_pressed')
        _quit.connect('pressed', self, '_on_quit_pressed')
    else:
        _start.disconnect('pressed', self, '_on_start_pressed')
        _options.disconnect('pressed', self, '_on_options_pressed')
        _credits.disconnect('pressed', self, '_on_credits_pressed')
        _quit.disconnect('pressed', self, '_on_quit_pressed')

func _set_focus_enabled(enabled: bool) -> void:
    for node in _focusable_nodes:
        if enabled:
            node.focus_mode = Control.FOCUS_ALL
            node.mouse_filter = Control.MOUSE_FILTER_PASS
        else:
            node.focus_mode = Control.FOCUS_NONE
            node.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_start_pressed() -> void:
    advance_to_menu(Menu.Menus.SAVE_SLOTS)

func _on_options_pressed() -> void:
    advance_to_menu(Menu.Menus.OPTIONS)

func _on_credits_pressed() -> void:
    set_input_enabled(false)

    var fade_duration := 2.0
    SceneChanger.change_scene_to(Preloads.CreditsScreen, fade_duration)

func _on_quit_pressed() -> void:
    advance_to_menu(Menu.Menus.QUIT)
