extends 'res://ui/menus/menu.gd'

const SECTION := 'game'

onready var _rumble: HBoxContainer = $Rumble
onready var _screenshake: HBoxContainer = $Screenshake

onready var _rumble_option_button: OptionButton = $Rumble/OptionButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

func _ready() -> void:
    _rumble.connect('option_changed', self, '_on_rumble_changed')
    _screenshake.connect('option_changed', self, '_on_screenshake_changed')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    _rumble_option_button.grab_focus()

func exit() -> void:
    self.visible = false

    Options.save_options()

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        if not _rumble.is_being_set() and not _screenshake.is_being_set():
            go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
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
