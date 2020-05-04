extends 'res://ui/menus/menu.gd'

onready var _music_slider: HSlider = $Music/Container/Slider
onready var _effects_slider: HSlider = $Effects/Container/Slider
onready var _ui_slider: HSlider = $UI/Container/Slider
onready var _back_button: Button = $Back

func _ready() -> void:
    _music_slider.connect('value_changed', self, '_on_music_value_changed')
    _effects_slider.connect('value_changed', self, '_on_effects_value_changed')
    _ui_slider.connect('value_changed', self, '_on_ui_value_changed')

    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    _music_slider.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        change_menu(Pause.Menu.AUDIO_OPTIONS, Pause.Menu.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        change_menu(Pause.Menu.AUDIO_OPTIONS, Pause.Menu.OPTIONS)

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_music_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()

func _on_effects_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()

func _on_ui_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()

    # Convert integer slider value [0, 10] to decibel value [-80, 0].
    var bus_index := AudioServer.get_bus_index('UI')
    var old_volume_db := AudioServer.get_bus_volume_db(bus_index)
    var new_volume_db := max(linear2db(new_value / _ui_slider.max_value), -80)
    AudioServer.set_bus_volume_db(bus_index, new_volume_db)

func _on_back_pressed() -> void:
    change_menu(Pause.Menu.AUDIO_OPTIONS, Pause.Menu.OPTIONS)
