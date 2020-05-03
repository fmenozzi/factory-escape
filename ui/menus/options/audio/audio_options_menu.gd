extends 'res://ui/menus/menu.gd'

onready var _music_slider: HSlider = $Music/Container/Slider
onready var _effects_slider: HSlider = $Effects/Container/Slider
onready var _ui_slider: HSlider = $UI/Container/Slider
onready var _back_button: Button = $Back

func _ready() -> void:
    _music_slider.connect('value_changed', self, '_on_music_value_changed')
    _effects_slider.connect('value_changed', self, '_on_effects_value_changed')
    _ui_slider.connect('value_changed', self, '_on_ui_value_changed')

func enter(pause: Pause, previous_menu: int) -> void:
    self.visible = true

    _music_slider.grab_focus()

    _back_button.connect('pressed', self, '_on_back_pressed', [pause])

func exit(pause: Pause) -> void:
    self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        change_menu(pause.Menu.AUDIO_OPTIONS, pause.Menu.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        change_menu(pause.Menu.AUDIO_OPTIONS, pause.Menu.OPTIONS)

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_music_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()

func _on_effects_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()

func _on_ui_value_changed(new_value: float) -> void:
    emit_menu_navigation_sound()

func _on_back_pressed(pause: Pause) -> void:
    change_menu(pause.Menu.AUDIO_OPTIONS, pause.Menu.OPTIONS)
