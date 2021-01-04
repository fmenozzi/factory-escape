extends 'res://ui/menus/menu.gd'

signal quit_to_desktop_requested

onready var _yes: Button = $Yes
onready var _no: Button = $No

onready var _focusable_nodes := [
    _yes,
    _no,
]

func _ready() -> void:
    _yes.connect('pressed', self, '_on_yes_pressed')
    _no.connect('pressed', self, '_on_no_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    self.visible = true

    _no.grab_focus()

    set_focus_signals_enabled_for_nodes(_focusable_nodes, true)

func exit() -> void:
    self.visible = false

    set_focus_signals_enabled_for_nodes(_focusable_nodes, false)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

func _on_yes_pressed() -> void:
    emit_signal('quit_to_desktop_requested')

func _on_no_pressed() -> void:
    go_to_previous_menu()
