extends 'res://ui/menus/menu.gd'

onready var _jump_button: Button = $Jump/Jump
onready var _attack_button: Button = $Attack/Attack
onready var _dash_button: Button = $Dash/Dash
onready var _interact_button: Button = $Interact/Interact

onready var _back_button: Button = $Back

func enter(pause: Pause, previous_menu: int) -> void:
	self.visible = true

	_jump_button.connect('pressed', self, '_on_jump_pressed', [pause])
	_attack_button.connect('pressed', self, '_on_attack_pressed', [pause])
	_dash_button.connect('pressed', self, '_on_dash_pressed', [pause])
	_interact_button.connect('pressed', self, '_on_interact_pressed', [pause])
	_back_button.connect('pressed', self, '_on_back_pressed', [pause])

	_jump_button.grab_focus()

func exit(pause: Pause) -> void:
	self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
	if event.is_action_pressed('ui_pause'):
		change_menu(pause.Menu.CONTROLLER_OPTIONS, pause.Menu.UNPAUSED)
	elif event.is_action_pressed('ui_cancel'):
		change_menu(pause.Menu.CONTROLLER_OPTIONS, pause.Menu.OPTIONS)

func _on_jump_pressed(pause: Pause) -> void:
	print('jump remapping not yet implemented')

func _on_attack_pressed(pause: Pause) -> void:
	print('attack remapping not yet implemented')

func _on_dash_pressed(pause: Pause) -> void:
	print('dash remapping not yet implemented')

func _on_interact_pressed(pause: Pause) -> void:
	print('interact remapping not yet implemented')

func _on_back_pressed(pause: Pause) -> void:
	change_menu(pause.Menu.CONTROLLER_OPTIONS, pause.Menu.OPTIONS)