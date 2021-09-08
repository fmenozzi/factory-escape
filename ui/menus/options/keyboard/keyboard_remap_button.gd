extends Button

signal remap_started
signal remap_finished

export(String) var action := ''

var _scancode := -1

func _ready() -> void:
    assert(InputMap.has_action(action))

    set_process_unhandled_key_input(false)
    update_key_display()

func _toggled(button_pressed: bool) -> void:
    # Consume event corresponding to the toggle itself; the NEXT event is the
    # one used for remapping.
    accept_event()

    set_process_unhandled_key_input(button_pressed)
    self.disabled = button_pressed

    if button_pressed:
        release_focus()
        emit_signal('remap_started')
    else:
        update_key_display()

func _unhandled_key_input(event: InputEventKey) -> void:
    if remap_action_to(event):
        self.pressed = false
        emit_signal('remap_finished')

func get_scancode() -> int:
    return _scancode

func remap_action_to(new_event: InputEventKey) -> bool:
    var remap_succeeded: bool = Controls.remap_keyboard_action(action, new_event)
    if not remap_succeeded:
        return false

    update_key_display()

    return true

func update_key_display() -> void:
    var current_key_scancode: int = Controls.get_scancode_for_action(action)
    if current_key_scancode == -1:
        return

    _scancode = current_key_scancode
    self.text = OS.get_scancode_string(_scancode)
