extends 'res://ui/menu.gd'

onready var _yes: Button = $Yes
onready var _no: Button = $No

func enter(pause: Pause) -> void:
	_yes.connect('pressed', self, '_on_yes_pressed')

	_no.connect('pressed', self, '_on_no_pressed', [pause])
	_no.grab_focus()

	self.visible = true

func exit(pause: Pause) -> void:
	self.visible = false

func handle_input(pause: Pause, event: InputEvent):
	if event.is_action_pressed('ui_pause'):
		emit_signal('menu_changed', pause.Menu.QUIT, pause.Menu.UNPAUSED)

func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed(pause: Pause) -> void:
	emit_signal('menu_changed', pause.Menu.QUIT, pause.Menu.PAUSE)