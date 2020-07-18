extends 'res://ui/menus/menu.gd'

const SECTION := 'video'

onready var _vsync: HBoxContainer = $VSync
onready var _window_mode: HBoxContainer = $WindowMode

onready var _vsync_option_button: OptionButton = $VSync/OptionButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

func _ready() -> void:
    _vsync.connect('option_changed', self, '_on_vsync_changed')
    _window_mode.connect('option_changed', self, '_on_window_mode_changed')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    _vsync_option_button.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        if not _vsync.is_being_set() and not _window_mode.is_being_set():
            go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func get_options_data() -> Array:
    return [SECTION, {
        'vsync': _vsync.get_selected_option_name(),
        'window_mode': _window_mode.get_selected_option_name(),
    }]

func load_options_data(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'vsync'):
        _vsync.select_option(config.get_value(SECTION, 'vsync'))
        _set_vsync()

    if config.has_section_key(SECTION, 'window_mode'):
        _window_mode.select_option(config.get_value(SECTION, 'window_mode'))
        _set_window_mode()

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

func _on_vsync_changed() -> void:
    _set_vsync()

    Options.save_options()

func _on_window_mode_changed() -> void:
    _set_window_mode()

    Options.save_options()

func _on_reset_to_defaults_pressed() -> void:
    _vsync.reset_to_default()
    _set_vsync()

    _window_mode.reset_to_default()
    _set_window_mode()

    Options.save_options()

func _on_back_pressed() -> void:
    go_to_previous_menu()
