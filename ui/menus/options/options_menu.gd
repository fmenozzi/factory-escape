extends 'res://ui/menus/menu.gd'

onready var _game: Button = $Game
onready var _audio: Button = $Audio
onready var _video: Button = $Video
onready var _controller: Button = $Controller
onready var _keyboard: Button = $Keyboard
onready var _back: Button = $Back

func enter(pause: Pause, previous_menu: int) -> void:
	_game.connect('pressed', self, '_on_game_pressed', [pause])
	_audio.connect('pressed', self, '_on_audio_pressed', [pause])
	_video.connect('pressed', self, '_on_video_pressed', [pause])
	_controller.connect('pressed', self, '_on_controller_pressed', [pause])
	_keyboard.connect('pressed', self, '_on_keyboard_pressed', [pause])
	_back.connect('pressed', self, '_on_back_pressed', [pause])

	self.visible = true
	_game.grab_focus()

func exit(pause: Pause) -> void:
	self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
	if event.is_action_pressed('ui_pause'):
		emit_signal('menu_changed', pause.Menu.PAUSE, pause.Menu.UNPAUSED)
	elif event.is_action_pressed('ui_cancel'):
		emit_signal('menu_changed', pause.Menu.OPTIONS, pause.Menu.PAUSE)

func _on_game_pressed(pause: Pause) -> void:
	print('game button not yet implemented')

func _on_audio_pressed(pause: Pause) -> void:
	print('audio button not yet implemented')

func _on_video_pressed(pause: Pause) -> void:
	emit_signal('menu_changed', pause.Menu.OPTIONS, pause.Menu.VIDEO_OPTIONS)

func _on_controller_pressed(pause: Pause) -> void:
	print('controller button not yet implemented')

func _on_keyboard_pressed(pause: Pause) -> void:
	print('keyboard button not yet implemented')

func _on_back_pressed(pause: Pause) -> void:
	emit_signal('menu_changed', pause.Menu.OPTIONS, pause.Menu.PAUSE)