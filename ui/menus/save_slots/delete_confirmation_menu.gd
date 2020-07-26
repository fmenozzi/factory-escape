extends 'res://ui/menus/menu.gd'

onready var _yes: Button = $Yes
onready var _no: Button = $No

func _ready() -> void:
    _yes.connect('pressed', self, '_on_yes_pressed')
    _no.connect('pressed', self, '_on_no_pressed')

func enter(previous_menu: int) -> void:
    self.visible = true

    _no.grab_focus()

func exit() -> void:
    self.visible = false

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_yes_pressed() -> void:
    pass

func _on_no_pressed() -> void:
    go_to_previous_menu()
