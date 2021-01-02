extends 'res://ui/menus/menu.gd'

const SECTION := 'video'

onready var _vsync: HBoxContainer = $VSync
onready var _window_mode: HBoxContainer = $WindowMode
onready var _fps_cap: HBoxContainer = $FpsCap

onready var _vsync_option_button: OptionButton = $VSync/OptionButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

func _ready() -> void:
    _vsync.connect('option_changed', self, '_on_vsync_changed')
    _window_mode.connect('option_changed', self, '_on_window_mode_changed')
    _fps_cap.connect('option_changed', self, '_on_fps_cap_changed')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    _vsync_option_button.grab_focus()

func exit() -> void:
    self.visible = false

    Options.save_options_and_report_errors()

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        if not _vsync.is_being_set() and        \
           not _window_mode.is_being_set() and  \
           not _fps_cap.is_being_set():
            go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func get_options_data() -> Array:
    return [SECTION, {
        'vsync': _vsync.get_selected_option_name(),
        'window_mode': _window_mode.get_selected_option_name(),
        'fps_cap': _fps_cap.get_selected_option_name(),
    }]

func load_options_version_0_1_0(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'vsync'):
        _vsync.select_option(config.get_value(SECTION, 'vsync'))
        _set_vsync()

    if config.has_section_key(SECTION, 'window_mode'):
        _window_mode.select_option(config.get_value(SECTION, 'window_mode'))
        _set_window_mode()

    if config.has_section_key(SECTION, 'fps_cap'):
        _fps_cap.select_option(config.get_value(SECTION, 'fps_cap'))
        _set_fps_cap()

func reset_to_defaults() -> void:
    _vsync.reset_to_default()
    _set_vsync()

    _window_mode.reset_to_default()
    _set_window_mode()

    _fps_cap.reset_to_default()
    _set_fps_cap()

# Sets OS-level vsync using the currently-selected option in the option button.
func _set_vsync() -> void:
    OS.set_use_vsync(_vsync.get_selected_option_name() == 'Enabled')

# Sets OS-level window mode using the currently-selection option in the window
# mode button.
func _set_window_mode() -> void:
    var window_mode: String = _window_mode.get_selected_option_name()
    assert(window_mode in ['Fullscreen', 'Windowed'])

    match window_mode:
        'Fullscreen':
            OS.window_fullscreen = true

        'Windowed':
            OS.window_fullscreen = false

func _set_fps_cap() -> void:
    var fps_cap: String = _fps_cap.get_selected_option_name()
    assert(fps_cap in ['None', '30', '60'])

    match fps_cap:
        'None':
            Engine.target_fps = 0

        '30':
            Engine.target_fps = 30

        '60':
            Engine.target_fps = 60

func _on_vsync_changed() -> void:
    _set_vsync()

func _on_window_mode_changed() -> void:
    _set_window_mode()

func _on_fps_cap_changed() -> void:
    _set_fps_cap()

func _on_reset_to_defaults_pressed() -> void:
    reset_to_defaults()

func _on_back_pressed() -> void:
    go_to_previous_menu()
