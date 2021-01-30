extends 'res://ui/menus/menu.gd'

const SECTION := 'game'

onready var _rumble: HBoxContainer = $Rumble
onready var _screenshake: HBoxContainer = $Screenshake

onready var _rumble_option_button: OptionButton = $Rumble/OptionButton
onready var _screenshake_option_button: OptionButton = $Screenshake/OptionButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

onready var _focusable_nodes := [
    _rumble_option_button,
    _screenshake_option_button,
    _reset_to_defaults,
    _back_button,
]

func _ready() -> void:
    _rumble.connect('option_changed', self, '_on_rumble_changed')
    _screenshake.connect('option_changed', self, '_on_screenshake_changed')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_rumble_option_button)

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    if Controls.get_mode() == Controls.Mode.CONTROLLER:
        get_default_focusable_node().grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    Options.save_options_and_report_errors()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        if not _rumble.is_being_set() and not _screenshake.is_being_set():
            go_to_previous_menu()
    elif event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        if _rumble.is_being_set() or _screenshake.is_being_set():
            emit_menu_navigation_sound()

func get_options_data() -> Array:
    return [SECTION, {
        'rumble': _rumble.get_selected_option_name(),
        'screenshake': _screenshake.get_selected_option_name(),
    }]

func load_options_version_0_1_0(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'rumble'):
        _rumble.select_option(config.get_value(SECTION, 'rumble'))
        _set_rumble()

    if config.has_section_key(SECTION, 'screenshake'):
        _screenshake.select_option(config.get_value(SECTION, 'screenshake'))
        _set_screenshake()

func reset_to_defaults() -> void:
    _rumble.reset_to_default()
    _set_rumble()

    _screenshake.reset_to_default()
    _set_screenshake()

func _set_rumble() -> void:
    var rumble: String = _rumble.get_selected_option_name()
    assert(rumble in ['Normal', 'Less', 'None'])

    match rumble:
        'Normal':
            Rumble.set_strength_multiplier(1.0)

        'Less':
            Rumble.set_strength_multiplier(0.5)

        'None':
            Rumble.set_strength_multiplier(0.0)

func _set_screenshake() -> void:
    var screenshake: String = _screenshake.get_selected_option_name()
    assert(screenshake in ['Normal', 'Less', 'None'])

    match screenshake:
        'Normal':
            Screenshake.set_strength_multiplier(1.0)

        'Less':
            Screenshake.set_strength_multiplier(0.5)

        'None':
            Screenshake.set_strength_multiplier(0.0)

func _on_rumble_changed() -> void:
    _set_rumble()

func _on_screenshake_changed() -> void:
    _set_screenshake()

func _on_reset_to_defaults_pressed() -> void:
    reset_to_defaults()

func _on_back_pressed() -> void:
    go_to_previous_menu()
