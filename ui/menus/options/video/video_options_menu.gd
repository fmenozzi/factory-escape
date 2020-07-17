extends 'res://ui/menus/menu.gd'

const SECTION := 'video'

onready var _vsync: CheckBox = $VSync
onready var _fullscreen: CheckBox = $Fullscreen

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

func _ready() -> void:
    _vsync.connect('pressed', self, '_on_vsync_pressed')
    _fullscreen.connect('pressed', self, '_on_fullscreen_pressed')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

    _vsync.pressed = OS.vsync_enabled
    _fullscreen.pressed = OS.window_fullscreen

func enter(previous_menu: int) -> void:
    self.visible = true

    _vsync.grab_focus()

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

func get_options_data() -> Array:
    return [SECTION, {
        'vsync': OS.vsync_enabled,
        'fullscreen': OS.window_fullscreen,
    }]

func load_options_data(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'vsync'):
        var vsync: bool = config.get_value(SECTION, 'vsync')
        OS.set_use_vsync(vsync)
        _vsync.pressed = vsync

    if config.has_section_key(SECTION, 'fullscreen'):
        var fullscreen: bool = config.get_value(SECTION, 'fullscreen')
        OS.window_fullscreen = fullscreen
        _fullscreen.pressed = fullscreen

func _on_vsync_pressed() -> void:
    OS.set_use_vsync(_vsync.is_pressed())
    Options.save_options()

func _on_fullscreen_pressed() -> void:
    OS.set_window_fullscreen(_fullscreen.is_pressed())
    Options.save_options()

func _on_reset_to_defaults_pressed() -> void:
    OS.set_use_vsync(true)
    _vsync.pressed = true

    OS.set_window_fullscreen(false)
    _fullscreen.pressed = false

    Options.save_options()

func _on_back_pressed() -> void:
    go_to_previous_menu()
