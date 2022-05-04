extends 'res://ui/menus/menu.gd'

const SECTION := 'audio'

onready var _music_slider: AudioSlider = $Music
onready var _effects_slider: AudioSlider = $Effects
onready var _ui_slider: AudioSlider = $UI

onready var _music_cycle_options_button: CycleOptionsButton = $Music/CycleOptionsButton
onready var _effects_cycle_options_button: CycleOptionsButton = $Effects/CycleOptionsButton
onready var _ui_cycle_options_button: CycleOptionsButton = $UI/CycleOptionsButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

onready var _focusable_nodes := [
    _music_cycle_options_button,
    _effects_cycle_options_button,
    _ui_cycle_options_button,
    _reset_to_defaults,
    _back_button,
]

func _ready() -> void:
    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_music_cycle_options_button)

func _process(delta: float) -> void:
    # This has to be moved to process because InputEvent doesn't have a similar
    # is_action_just_pressed() method, and putting this block in handle_input()
    # causes duplication in the number of events fired for some reason (e.g. it
    # returns true for two frames instead of one).
    if Input.is_action_just_pressed('ui_left'):
        if _music_cycle_options_button.has_focus():
            _music_cycle_options_button.select_previous_option()
            emit_menu_navigation_sound()
        elif _effects_cycle_options_button.has_focus():
            _effects_cycle_options_button.select_previous_option()
            emit_menu_navigation_sound()
        elif _ui_cycle_options_button.has_focus():
            _ui_cycle_options_button.select_previous_option()
            emit_menu_navigation_sound()
    elif Input.is_action_just_pressed('ui_right'):
        if _music_cycle_options_button.has_focus():
            _music_cycle_options_button.select_next_option()
            emit_menu_navigation_sound()
        elif _effects_cycle_options_button.has_focus():
            _effects_cycle_options_button.select_next_option()
            emit_menu_navigation_sound()
        elif _ui_cycle_options_button.has_focus():
            _ui_cycle_options_button.select_next_option()
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
        'music': _music_slider.get_value(),
        'effects': _effects_slider.get_value(),
        'ui': _ui_slider.get_value(),
    }]

func load_options_version_0_1_0(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'music'):
        var music: float = config.get_value(SECTION, 'music')
        _set_bus_volume('Music', music)
        _music_slider.set_value(music)

    if config.has_section_key(SECTION, 'effects'):
        var effects: float = config.get_value(SECTION, 'effects')
        _set_bus_volume('Effects', effects)
        _effects_slider.set_value(effects)

    if config.has_section_key(SECTION, 'ui'):
        var ui: float = config.get_value(SECTION, 'ui')
        _set_bus_volume('UI', ui)
        _ui_slider.set_value(ui)

    _music_slider.connect('value_changed', self, '_on_music_value_changed')
    _effects_slider.connect('value_changed', self, '_on_effects_value_changed')
    _ui_slider.connect('value_changed', self, '_on_ui_value_changed')

func reset_to_defaults() -> void:
    _music_slider.set_value(_music_slider.max_value())
    _effects_slider.set_value(_effects_slider.max_value())
    _ui_slider.set_value(_ui_slider.max_value())

    Options.save_options_and_report_errors()

func _set_bus_volume(bus: String, slider_value: float) -> void:
    assert(bus in ['Music', 'Effects', 'Death', 'UI'])

    var slider: AudioSlider
    match bus:
        'Music':
            slider = _music_slider
        'Effects', 'Death':
            slider = _effects_slider
        'UI':
            slider = _ui_slider

    # Convert integer slider value [0, 10] to decibel value [-80, 0]. If the
    # game is paused (which reduces the music volume), make sure we take that
    # into account.
    Audio.set_bus_max_volume_linear(bus, slider_value / slider.max_value())
    if bus == 'Music' and get_tree().paused:
        Audio.set_bus_volume_linear(
            'Music',
            Pause.get_pause_volume_factor() * Audio.get_bus_max_volume_linear('Music'))

func _on_music_value_changed() -> void:
    emit_menu_navigation_sound()
    _set_bus_volume('Music', _music_slider.get_value())

func _on_effects_value_changed() -> void:
    emit_menu_navigation_sound()
    _set_bus_volume('Effects', _effects_slider.get_value())
    _set_bus_volume('Death', _effects_slider.get_value())

func _on_ui_value_changed() -> void:
    emit_menu_navigation_sound()
    _set_bus_volume('UI', _ui_slider.get_value())

func _on_reset_to_defaults_pressed() -> void:
    reset_to_defaults()

func _on_back_pressed() -> void:
    go_to_previous_menu()
