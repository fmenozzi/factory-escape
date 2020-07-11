extends Button

signal remap_started
signal remap_finished

export(String) var action := ''

func _ready() -> void:
    assert(InputMap.has_action(action))

    set_process_unhandled_key_input(false)
    _display_current_key()

func _toggled(button_pressed: bool) -> void:
    # Consume event corresponding to the toggle itself; the NEXT event is the
    # one used for remapping.
    accept_event()

    set_process_unhandled_key_input(button_pressed)
    self.disabled = button_pressed

    if button_pressed:
        emit_signal('remap_started')
    else:
        _display_current_key()

func _unhandled_key_input(event: InputEventKey) -> void:
    _remap_action_to(event)
    self.pressed = false
    emit_signal('remap_finished')

func _remap_action_to(event: InputEventKey) -> void:
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, event)
    _display_current_key()

func _display_current_key() -> void:
    for event in InputMap.get_action_list(action):
        if event is InputEventKey:
            self.text = event.as_text()
