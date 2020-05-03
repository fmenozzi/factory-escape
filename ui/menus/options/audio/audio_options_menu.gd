extends 'res://ui/menus/menu.gd'

onready var _music_slider: HSlider = $Music/Container/Slider
onready var _back_button: Button = $Back

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

func _on_back_pressed(pause: Pause) -> void:
    change_menu(pause.Menu.AUDIO_OPTIONS, pause.Menu.OPTIONS)
