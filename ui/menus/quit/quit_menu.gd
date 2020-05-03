extends 'res://ui/menus/menu.gd'

onready var _yes: Button = $Yes
onready var _no: Button = $No

func enter(pause: Pause, previous_menu: int) -> void:
    _yes.connect('pressed', self, '_on_yes_pressed')

    _no.connect('pressed', self, '_on_no_pressed', [pause])
    _no.grab_focus()

    self.visible = true

func exit(pause: Pause) -> void:
    self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
    if event.is_action_pressed('ui_pause'):
        change_menu(Pause.Menu.QUIT, Pause.Menu.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        change_menu(Pause.Menu.QUIT, Pause.Menu.PAUSE)

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func _on_yes_pressed() -> void:
    get_tree().quit()

func _on_no_pressed(pause: Pause) -> void:
    change_menu(Pause.Menu.QUIT, Pause.Menu.PAUSE)
