extends Node

signal mode_changed(new_mode)
signal control_remapped(player_action, new_event)

enum Mode {
    CONTROLLER,
    KEYBOARD,
}

var _mode: int = Mode.CONTROLLER

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

var _joypad_motions_to_textures: Dictionary = {
    # Left stick.
    JOY_ANALOG_LX: Preloads.XboxLs,
    JOY_ANALOG_LY: Preloads.XboxLs,

    # Right stick.
    JOY_ANALOG_RX: Preloads.XboxRs,
    JOY_ANALOG_RY: Preloads.XboxRs,
}

# Controller buttons that can be used to remap actions. Controller motions (i.e.
# sticks), and the start/options/dpad buttons cannot be remapped.
const _CONTROLLER_REMAP_ALLOWLIST := [
    # Main buttons.
    JOY_XBOX_A,
    JOY_XBOX_B,
    JOY_XBOX_X,
    JOY_XBOX_Y,

    # Bumbers and triggers.
    JOY_L,
    JOY_R,
    JOY_L2,
    JOY_R2,
]

# Keyboard scancodes that cannot be used to remap actions.
const _KEYBOARD_REMAP_BLOCKLIST := [
    KEY_ESCAPE,
    KEY_ENTER,
    KEY_KP_ENTER,
]

func _ready() -> void:
    pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        if _mode == Mode.KEYBOARD:
            _set_mode(Mode.CONTROLLER)

    if event is InputEventKey or event is InputEventMouse:
        if _mode == Mode.CONTROLLER:
            _set_mode(Mode.KEYBOARD)

func _set_mode(new_mode: int) -> void:
    assert(new_mode in [Mode.CONTROLLER, Mode.KEYBOARD])

    _mode = new_mode

    emit_signal('mode_changed', new_mode)

func get_mode() -> int:
    return _mode

func is_up_action_pressed() -> bool:
    return Input.is_action_pressed('player_move_up') or \
           Input.is_action_pressed('player_look_up_controller') or \
           Input.is_action_pressed('player_look_up_keyboard')

func remap_controller_action(
    player_action: String,
    new_event: InputEventJoypadButton
) -> bool:
    # Make sure the desired remapping is allowed.
    if not new_event.button_index in _CONTROLLER_REMAP_ALLOWLIST:
        return false

    # Check to see if the new event is already mapped to an existing option, and
    # if so, swap the mappings.
    for action in InputMap.get_actions():
        if action == player_action:
            continue

        # Make sure we only looking at player_ actions (and not e.g. ui_
        # actions).
        if not action.begins_with('player_'):
            continue

        for event in InputMap.get_action_list(action):
            if event is InputEventJoypadButton and event.button_index == new_event.button_index:
                # Swap the mappings.
                _remap_controller_action(action, _get_first_joy_event_for_action(player_action))
                _remap_controller_action(player_action, new_event)
                return true

    # If the new event is not already mapped to an existing option, perform the
    # remapping as usual.
    _remap_controller_action(player_action, new_event)
    return true

func remap_keyboard_action(
    player_action: String,
    new_event: InputEventKey
) -> bool:
    # Make sure the desired remapping is allowed.
    if new_event.scancode in _KEYBOARD_REMAP_BLOCKLIST:
        return false

    # Check to see if the new event is already mapped to an existing option, and
    # if so, swap the mappings.
    for action in InputMap.get_actions():
        if action == player_action:
            continue

        # Make sure we only looking at player_ actions (and not e.g. ui_
        # actions).
        if not action.begins_with('player_'):
            continue

        for event in InputMap.get_action_list(action):
            if event is InputEventKey and event.scancode == new_event.scancode:
                # Swap the mappings.
                _remap_keyboard_action(action, _get_first_key_event_for_action(player_action))
                _remap_keyboard_action(player_action, new_event)
                return true

    # If the new event is not already mapped to an existing option, perform the
    # remapping as usual.
    _remap_keyboard_action(player_action, new_event)
    return true

func get_scancode_for_action(player_action: String) -> int:
    for event in InputMap.get_action_list(player_action):
        if event is InputEventKey:
            # Make sure the desired remapping is allowed.
            if not event.scancode in _KEYBOARD_REMAP_BLOCKLIST:
                return event.scancode

    return -1

func get_button_index_for_action(player_action: String) -> int:
    for event in InputMap.get_action_list(player_action):
        if event is InputEventJoypadButton:
            # Make sure the desired remapping is allowed.
            if event.button_index in _CONTROLLER_REMAP_ALLOWLIST:
                return event.button_index

    return -1

func get_texture_for_joypad_button(button_index: int) -> Texture:
    assert(button_index in _joypad_buttons_to_textures)

    return _joypad_buttons_to_textures[button_index]

func get_texture_for_joypad_motion(axis: int) -> Texture:
    assert(axis in _joypad_motions_to_textures)

    return _joypad_motions_to_textures[axis]

func get_joypad_texture_for_action(player_action: String) -> Texture:
    var texture: Texture = null

    for event in InputMap.get_action_list(player_action):
        if event is InputEventJoypadButton:
            return get_texture_for_joypad_button(event.button_index)

        if event is InputEventJoypadMotion:
            return get_texture_for_joypad_motion(event.axis)

    assert(false, 'Could not find a joypad texture for action %s' % player_action)

    return null

func _remap_controller_action(player_action: String, new_event: InputEventJoypadButton) -> void:
    # Remove all joypad events corresponding to the player action before adding
    # the new mapping.
    for existing_event in InputMap.get_action_list(player_action):
        if existing_event is InputEventJoypadButton:
            InputMap.action_erase_event(player_action, existing_event)
    InputMap.action_add_event(player_action, new_event)
    emit_signal('control_remapped', player_action, new_event)

func _remap_keyboard_action(player_action: String, new_event: InputEventKey) -> void:
    # Remove all keyboard events corresponding to the player action before
    # adding the new mapping.
    for existing_event in InputMap.get_action_list(player_action):
        if existing_event is InputEventKey:
            InputMap.action_erase_event(player_action, existing_event)
    InputMap.action_add_event(player_action, new_event)
    emit_signal('control_remapped', player_action, new_event)

func _get_first_joy_event_for_action(player_action: String) -> InputEventJoypadButton:
    for event in InputMap.get_action_list(player_action):
        if event is InputEventJoypadButton:
            return event
    return null

func _get_first_key_event_for_action(player_action: String) -> InputEventKey:
    for event in InputMap.get_action_list(player_action):
        if event is InputEventKey:
            return event
    return null
