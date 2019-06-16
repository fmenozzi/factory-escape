extends 'res://ui/menu.gd'

onready var _yes: Button = $Yes
onready var _no: Button = $No

func enter(pause_node) -> void:
	_yes.connect('pressed', self, '_on_yes_pressed')

	_no.connect('pressed', self, '_on_no_pressed', [pause_node])
	_no.grab_focus()

	self.visible = true

func exit(pause_node) -> void:
	self.visible = false

func handle_input(pause_node, event: InputEvent):
	if event.is_action_pressed('ui_pause'):
		emit_signal('menu_changed', pause_node.Menu.QUIT, pause_node.Menu.UNPAUSED)

func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed(pause_node) -> void:
	emit_signal('menu_changed', pause_node.Menu.QUIT, pause_node.Menu.PAUSE)