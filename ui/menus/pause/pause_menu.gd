extends 'res://ui/menus/menu.gd'

onready var _resume: Button = $Resume
onready var _options: Button = $Options
onready var _quit: Button = $Quit

func enter(pause: Pause, previous_menu: int) -> void:
    _resume.connect('pressed', self, '_on_resume_pressed', [pause])
    _options.connect('pressed', self, '_on_options_pressed', [pause])
    _quit.connect('pressed', self, '_on_quit_pressed', [pause])

    self.visible = true

    match previous_menu:
        pause.Menu.OPTIONS:
            _options.grab_focus()
        pause.Menu.QUIT:
            _quit.grab_focus()
        _:
            _resume.grab_focus()

func exit(pause: Pause) -> void:
    self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause') or event.is_action_pressed('ui_cancel'):
        change_menu(pause.Menu.PAUSE, pause.Menu.UNPAUSED)

func _on_resume_pressed(pause: Pause) -> void:
    change_menu(pause.Menu.PAUSE, pause.Menu.UNPAUSED)

func _on_options_pressed(pause: Pause) -> void:
    change_menu(pause.Menu.PAUSE, pause.Menu.OPTIONS)

func _on_quit_pressed(pause: Pause) -> void:
    change_menu(pause.Menu.PAUSE, pause.Menu.QUIT)
