extends Control

onready var _resume: Button = $MenuBackground/MainMenu/Resume
onready var _options: Button = $MenuBackground/MainMenu/Options
onready var _quit: Button = $MenuBackground/MainMenu/Quit

func _ready() -> void:
	_resume.connect('pressed', self, '_on_resume_pressed')
	_options.connect('pressed', self, '_on_options_pressed')
	_quit.connect('pressed', self, '_on_quit_pressed')

func _input(event: InputEvent) -> void:
	# Toggle pause state and give the resume button focus.
	if event.is_action_pressed('ui_pause'):
		_toggle_pause()
		_resume.grab_focus()
		
func _toggle_pause() -> void:
	var new_pause_state := not get_tree().paused
	get_tree().paused = new_pause_state
	self.visible = new_pause_state
		
func _on_resume_pressed() -> void:
	_toggle_pause()
	
func _on_options_pressed() -> void:
	print('options button not yet implemented')
		
func _on_quit_pressed() -> void:
	get_tree().quit()
