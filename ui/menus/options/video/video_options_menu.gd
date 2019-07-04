extends 'res://ui/menus/menu.gd'

onready var _vsync: CheckBox = $VSync
onready var _fullscreen: CheckBox = $Fullscreen

func _ready() -> void:
    _vsync.connect('pressed', self, '_on_vsync_pressed')
    _fullscreen.connect('pressed', self, '_on_fullscreen_pressed')

func enter(pause: Pause, previous_menu: int) -> void:
    self.visible = true

    _vsync.grab_focus()

func exit(pause: Pause) -> void:
    self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        change_menu(pause.Menu.VIDEO_OPTIONS, pause.Menu.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        change_menu(pause.Menu.VIDEO_OPTIONS, pause.Menu.OPTIONS)

func _on_vsync_pressed() -> void:
    # TODO: Save this somewhere persistent as well.
    OS.set_use_vsync(_vsync.is_pressed())

func _on_fullscreen_pressed() -> void:
    # TODO: Save this somewhere persistent as well.
    OS.set_window_fullscreen(_fullscreen.is_pressed())
