extends 'res://ui/menu.gd'

onready var _resume: Button = $Resume
onready var _options: Button = $Options
onready var _quit: Button = $Quit

func enter(pause_node) -> void:
	_resume.connect('pressed', self, '_on_resume_pressed', [pause_node])
	_options.connect('pressed', self, '_on_options_pressed', [pause_node])
	_quit.connect('pressed', self, '_on_quit_pressed', [pause_node])

	self.visible = true
	_resume.grab_focus()

func exit(pause_node) -> void:
	self.visible = false

func handle_input(pause_node, event: InputEvent):
	if event.is_action_pressed('ui_pause'):
		emit_signal('menu_changed', pause_node.Menu.PAUSE, pause_node.Menu.UNPAUSED)

func _on_resume_pressed(pause_node) -> void:
	emit_signal('menu_changed', pause_node.Menu.PAUSE, pause_node.Menu.UNPAUSED)

func _on_options_pressed(pause_node) -> void:
	print('options button not yet implemented')

func _on_quit_pressed(pause_node) -> void:
	emit_signal('menu_changed', pause_node.Menu.PAUSE, pause_node.Menu.QUIT)
