extends Button

signal remap_started
signal remap_finished

export(String) var action := ''

var _joypad_buttons_to_textures: Dictionary = {
    # Main buttons.
    JOY_XBOX_A: Preloads.XboxA,
    JOY_XBOX_B: Preloads.XboxB,
    JOY_XBOX_X: Preloads.XboxX,
    JOY_XBOX_Y: Preloads.XboxY,

    # Bumbers and triggers.
    JOY_L:  Preloads.XboxLb,
    JOY_R:  Preloads.XboxRb,
    JOY_L2: Preloads.XboxLt,
    JOY_R2: Preloads.XboxRt,

    # D-pad.
    JOY_DPAD_UP:    Preloads.XboxDpadUp,
    JOY_DPAD_RIGHT: Preloads.XboxDpadRight,
    JOY_DPAD_DOWN:  Preloads.XboxDpadDown,
    JOY_DPAD_LEFT:  Preloads.XboxDpadLeft,
}

func _ready() -> void:
    assert(InputMap.has_action(action))

    set_process_unhandled_input(false)
    _display_current_texture()

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
        _display_current_texture()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventJoypadButton:
        return

    if _remap_action_to(event as InputEventJoypadButton):
        self.pressed = false
        emit_signal('remap_finished')

func _remap_action_to(event: InputEventJoypadButton) -> bool:
    # Make sure the desired remapping is allowed.
    if not _joypad_buttons_to_textures.has(event.button_index):
        return false

    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, event)
    _display_current_texture()

    return true

func _display_current_texture() -> void:
    for event in InputMap.get_action_list(action):
        if event is InputEventJoypadButton:
            # Make sure the desired remapping is allowed.
            if _joypad_buttons_to_textures.has(event.button_index):
                self.icon = _joypad_buttons_to_textures[event.button_index]
