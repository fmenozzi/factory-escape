extends 'res://ui/menus/menu.gd'

const SECTION := 'video'

onready var _vsync: HBoxContainer = $VSync
onready var _window_mode: HBoxContainer = $WindowMode
onready var _fps_cap: HBoxContainer = $FpsCap

onready var _vsync_cycle_options_button: CycleOptionsButton = $VSync/CycleOptionsButton
onready var _window_mode_cycle_options_button: CycleOptionsButton = $WindowMode/CycleOptionsButton
onready var _fps_cap_cycle_options_button: CycleOptionsButton = $FpsCap/CycleOptionsButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

onready var _focusable_nodes := [
    _vsync_cycle_options_button,
    _window_mode_cycle_options_button,
    _fps_cap_cycle_options_button,
    _reset_to_defaults,
    _back_button,
]

func _ready() -> void:
    _vsync.connect('option_changed', self, '_on_vsync_changed')
    _window_mode.connect('option_changed', self, '_on_window_mode_changed')
    _fps_cap.connect('option_changed', self, '_on_fps_cap_changed')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_vsync_cycle_options_button)

func _process(delta: float) -> void:
    # This has to be moved to process because InputEvent doesn't have a similar
    # is_action_just_pressed() method, and putting this block in handle_input()
    # causes duplication in the number of events fired for some reason (e.g. it
    # returns true for two frames instead of one).
    if Input.is_action_just_pressed('ui_left'):
        if _vsync_cycle_options_button.has_focus():
            _vsync_cycle_options_button.select_previous_option()
            emit_menu_navigation_sound()
        elif _window_mode_cycle_options_button.has_focus():
            _window_mode_cycle_options_button.select_previous_option()
            emit_menu_navigation_sound()
        elif _fps_cap_cycle_options_button.has_focus():
            _fps_cap_cycle_options_button.select_previous_option()
            emit_menu_navigation_sound()
    elif Input.is_action_just_pressed('ui_right'):
        if _vsync_cycle_options_button.has_focus():
            _vsync_cycle_options_button.select_next_option()
            emit_menu_navigation_sound()
        elif _window_mode_cycle_options_button.has_focus():
            _window_mode_cycle_options_button.select_next_option()
            emit_menu_navigation_sound()
        elif _fps_cap_cycle_options_button.has_focus():
            _fps_cap_cycle_options_button.select_next_option()
            emit_menu_navigation_sound()

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    set_process(true)

    if Controls.get_mode() == Controls.Mode.CONTROLLER:
        get_default_focusable_node().grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_process(false)

    Options.save_options_and_report_errors()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

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

    Options.save_options_and_report_errors()

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
