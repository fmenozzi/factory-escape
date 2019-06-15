extends 'res://ui/menu.gd'

onready var _resume: Button = $Resume
onready var _options: Button = $Options
onready var _quit: Button = $Quit

func _ready() -> void:
	_options.connect('pressed', self, '_on_options_pressed')
	_quit.connect('pressed', self, '_on_quit_pressed')

func enter(pause_node) -> void:
	_resume.connect('pressed', self, '_on_resume_pressed', [pause_node])
	_resume.grab_focus()
	
func exit(pause_node) -> void:
	pass
	
func handle_input(pause_node, event: InputEvent) -> int:
	return pause_node.Menu.NO_CHANGE
	
func _on_resume_pressed(pause_node) -> void:
	pause_node._toggle_pause()
	
func _on_options_pressed() -> void:
	print('options button not yet implemented')
	
func _on_quit_pressed() -> void:
	get_tree().quit()
