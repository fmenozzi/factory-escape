extends 'res://ui/menus/menu.gd'

onready var _resume: Button = $Resume
onready var _options: Button = $Options
onready var _quit: Button = $Quit

func enter(pause: Pause) -> void:
	_resume.connect('pressed', self, '_on_resume_pressed', [pause])
	_options.connect('pressed', self, '_on_options_pressed', [pause])
	_quit.connect('pressed', self, '_on_quit_pressed', [pause])

	self.visible = true
	_resume.grab_focus()

func exit(pause: Pause) -> void:
	self.visible = false

func handle_input(pause: Pause, event: InputEvent):
	if event.is_action_pressed('ui_pause'):
		emit_signal('menu_changed', pause.Menu.PAUSE, pause.Menu.UNPAUSED)

func _on_resume_pressed(pause: Pause) -> void:
	emit_signal('menu_changed', pause.Menu.PAUSE, pause.Menu.UNPAUSED)

func _on_options_pressed(pause: Pause) -> void:
	emit_signal('menu_changed', pause.Menu.PAUSE, pause.Menu.OPTIONS)

func _on_quit_pressed(pause: Pause) -> void:
	emit_signal('menu_changed', pause.Menu.PAUSE, pause.Menu.QUIT)
