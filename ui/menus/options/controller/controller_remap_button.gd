extends Button

signal remap_started
signal remap_finished

export(String) var action := ''

var _button_index := -1

func _ready() -> void:
    assert(InputMap.has_action(action))

    set_process_unhandled_input(false)
    update_texture_display()

func _toggled(button_pressed: bool) -> void:
    # Consume event corresponding to the toggle itself; the NEXT event is the
    # one used for remapping.
    accept_event()

    set_process_unhandled_input(button_pressed)
    self.disabled = button_pressed

    if button_pressed:
        release_focus()
        emit_signal('remap_started')
    else:
        update_texture_display()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventJoypadButton:
        return

    if remap_action_to(event as InputEventJoypadButton):
        self.pressed = false
        emit_signal('remap_finished')

func get_button_index() -> int:
    return _button_index

func remap_action_to(new_event: InputEventJoypadButton) -> bool:
    var remap_succeeded: bool = Controls.remap_controller_action(action, new_event)
    if not remap_succeeded:
        return false

    update_texture_display()

    return true

func update_texture_display() -> void:
    var current_button_index: int = Controls.get_button_index_for_action(action)
    if current_button_index == -1:
        return

    _button_index = current_button_index
    self.icon = Controls.get_texture_for_joypad_button(_button_index)
