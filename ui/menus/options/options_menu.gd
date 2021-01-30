extends 'res://ui/menus/menu.gd'

onready var _game: Button = $Game
onready var _audio: Button = $Audio
onready var _video: Button = $Video
onready var _controller: Button = $Controller
onready var _keyboard: Button = $Keyboard
onready var _back: Button = $Back

onready var _focusable_nodes := [
    _game,
    _audio,
    _video,
    _controller,
    _keyboard,
    _back,
]

func _ready() -> void:
    _game.connect('pressed', self, '_on_game_pressed')
    _audio.connect('pressed', self, '_on_audio_pressed')
    _video.connect('pressed', self, '_on_video_pressed')
    _controller.connect('pressed', self, '_on_controller_pressed')
    _keyboard.connect('pressed', self, '_on_keyboard_pressed')
    _back.connect('pressed', self, '_on_back_pressed')

    connect_mouse_entered_signals_to_menu(_focusable_nodes)
    set_default_focusable_node(_game)

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    if Controls.get_mode() == Controls.Mode.CONTROLLER:
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
                get_default_focusable_node().grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

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
