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

const _KEYBOARD_BLOCKLIST := [
    KEY_ESCAPE,
    KEY_ENTER,
    KEY_KP_ENTER,
]

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

func remap_controller_action(
    player_action: String,
    new_event: InputEventJoypadButton
) -> bool:
    # Make sure the desired remapping is allowed.
    if not _joypad_buttons_to_textures.has(new_event.button_index):
        return false

    # Remove all joypad events corresponding to the player action before adding
    # the new mapping.
    for existing_event in InputMap.get_action_list(player_action):
        if existing_event is InputEventJoypadButton:
            InputMap.action_erase_event(player_action, existing_event)
    InputMap.action_add_event(player_action, new_event)

    emit_signal('control_remapped', player_action, new_event)

    return true

func remap_keyboard_action(
    player_action: String,
    new_event: InputEventKey
) -> bool:
    # Make sure the desired remapping is allowed.
    if new_event.scancode in _KEYBOARD_BLOCKLIST:
        return false

    # Remove all keyboard events corresponding to the player action before
    # adding the new mapping.
    for existing_event in InputMap.get_action_list(player_action):
        if existing_event is InputEventKey:
            InputMap.action_erase_event(player_action, existing_event)
    InputMap.action_add_event(player_action, new_event)

    emit_signal('control_remapped', player_action, new_event)

    return true

func get_joypad_buttons_to_textures() -> Dictionary:
    return _joypad_buttons_to_textures
