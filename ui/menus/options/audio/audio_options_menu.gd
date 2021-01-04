extends 'res://ui/menus/menu.gd'

const SECTION := 'audio'

onready var _music_slider: HSlider = $Music/Container/Slider
onready var _effects_slider: HSlider = $Effects/Container/Slider
onready var _ui_slider: HSlider = $UI/Container/Slider

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

onready var _focusable_nodes := [
    _music_slider,
    _effects_slider,
    _ui_slider,
    _reset_to_defaults,
    _back_button,
]

func _ready() -> void:
    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    _music_slider.grab_focus()

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
        go_to_previous_menu()

func get_options_data() -> Array:
    return [SECTION, {
        'music': _music_slider.value,
        'effects': _effects_slider.value,
        'ui': _ui_slider.value,
    }]

func load_options_version_0_1_0(config: ConfigFile) -> void:
    if not config.has_section(SECTION):
        return

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
    _music_slider.set_value(_music_slider.max_value)
    _effects_slider.set_value(_effects_slider.max_value)
    _ui_slider.set_value(_ui_slider.max_value)

func _set_bus_volume(bus: String, slider_value: float) -> void:
    assert(bus in ['Music', 'Effects', 'UI'])

    var slider: HSlider
    match bus:
        'Music':
            slider = _music_slider
        'Effects':
            slider = _effects_slider
        'UI':
            slider = _ui_slider

    # Convert integer slider value [0, 10] to decibel value [-80, 0].
    var bus_index := AudioServer.get_bus_index(bus)
    var old_volume_db := AudioServer.get_bus_volume_db(bus_index)
    var new_volume_db := max(linear2db(slider_value / slider.max_value), -80)
    AudioServer.set_bus_volume_db(bus_index, new_volume_db)

func _on_music_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()
    _set_bus_volume('Music', new_value)

func _on_effects_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()
    _set_bus_volume('Effects', new_value)

func _on_ui_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()
    _set_bus_volume('UI', new_value)

func _on_reset_to_defaults_pressed() -> void:
    reset_to_defaults()

func _on_back_pressed() -> void:
    go_to_previous_menu()
