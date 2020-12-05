extends 'res://ui/menus/menu.gd'

onready var _game: Button = $Game
onready var _audio: Button = $Audio
onready var _video: Button = $Video
onready var _controller: Button = $Controller
onready var _keyboard: Button = $Keyboard
onready var _back: Button = $Back

func _ready() -> void:
    _game.connect('pressed', self, '_on_game_pressed')
    _audio.connect('pressed', self, '_on_audio_pressed')
    _video.connect('pressed', self, '_on_video_pressed')
    _controller.connect('pressed', self, '_on_controller_pressed')
    _keyboard.connect('pressed', self, '_on_keyboard_pressed')
    _back.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    match previous_menu:
        Menu.Menus.AUDIO_OPTIONS:
            _audio.grab_focus()
        Menu.Menus.VIDEO_OPTIONS:
            _video.grab_focus()
        Menu.Menus.CONTROLLER_OPTIONS:
            _controller.grab_focus()
        Menu.Menus.KEYBOARD_OPTIONS:
            _keyboard.grab_focus()
        _:
            # Default to first option.
            _game.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_game_pressed() -> void:
    advance_to_menu(Menu.Menus.GAME_OPTIONS)

func _on_audio_pressed() -> void:
    advance_to_menu(Menu.Menus.AUDIO_OPTIONS)

func _on_video_pressed() -> void:
    advance_to_menu(Menu.Menus.VIDEO_OPTIONS)

func _on_controller_pressed() -> void:
    advance_to_menu(Menu.Menus.CONTROLLER_OPTIONS)

func _on_keyboard_pressed() -> void:
    advance_to_menu(Menu.Menus.KEYBOARD_OPTIONS)

func _on_back_pressed() -> void:
    go_to_previous_menu()
