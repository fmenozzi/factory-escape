extends 'res://ui/menus/menu.gd'

const SECTION := 'keyboard'

onready var _menu_label: Label = $Keyboard
onready var _jump_remap_button: Button = $ContainerRow1/JumpRemapContainer/KeyboardRemapButton
onready var _attack_remap_button: Button = $ContainerRow1/AttackRemapContainer/KeyboardRemapButton
onready var _dash_remap_button: Button = $ContainerRow2/DashRemapContainer/KeyboardRemapButton
onready var _grapple_remap_button: Button = $ContainerRow2/GrappleRemapContainer/KeyboardRemapButton
onready var _interact_remap_button: Button = $ContainerRow3/InteractRemapContainer/KeyboardRemapButton
onready var _heal_remap_button: Button = $ContainerRow3/HealRemapContainer/KeyboardRemapButton

onready var _reset_to_defaults: Button = $ResetToDefaults
onready var _back_button: Button = $Back

var _input_enabled := true

func _ready() -> void:
    for remap_button in get_tree().get_nodes_in_group('keyboard_remap_button'):
        remap_button.connect('remap_started', self, '_on_remap_started')
        remap_button.connect('remap_finished', self, '_on_remap_finished')

    _reset_to_defaults.connect('pressed', self, '_on_reset_to_defaults_pressed')
    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int, metadata: Dictionary) -> void:
    _jump_remap_button.grab_focus()
    _set_input_enabled(true)

    self.visible = true

func exit() -> void:
    self.visible = false

    Options.save_options()

func handle_input(event: InputEvent) -> void:
    if not _input_enabled:
        return

    if event.is_action_pressed('ui_pause'):
        if get_tree().paused:
            advance_to_menu(Menu.Menus.UNPAUSED)
    elif event.is_action_pressed('ui_cancel'):
        go_to_previous_menu()

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        emit_menu_navigation_sound()

func get_options_data() -> Array:
    return [SECTION, {
        'player_jump': _jump_remap_button.get_scancode(),
        'player_attack': _attack_remap_button.get_scancode(),
        'player_dash': _dash_remap_button.get_scancode(),
        'player_grapple': _grapple_remap_button.get_scancode(),
        'player_interact': _interact_remap_button.get_scancode(),
        'player_heal': _heal_remap_button.get_scancode(),
    }]

func load_options_data(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'player_jump'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_jump')
        var remap_succeeded: bool = _jump_remap_button.remap_action_to(event)
        assert(remap_succeeded)

    if config.has_section_key(SECTION, 'player_attack'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_attack')
        var remap_succeeded: bool = _attack_remap_button.remap_action_to(event)
        assert(remap_succeeded)

    if config.has_section_key(SECTION, 'player_dash'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_dash')
        var remap_succeeded: bool = _dash_remap_button.remap_action_to(event)
        assert(remap_succeeded)

    if config.has_section_key(SECTION, 'player_grapple'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_grapple')
        var remap_succeeded: bool = _grapple_remap_button.remap_action_to(event)
        assert(remap_succeeded)

    if config.has_section_key(SECTION, 'player_interact'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_interact')
        var remap_succeeded: bool = _interact_remap_button.remap_action_to(event)
        assert(remap_succeeded)

    if config.has_section_key(SECTION, 'player_heal'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_heal')
        var remap_succeeded: bool = _heal_remap_button.remap_action_to(event)
        assert(remap_succeeded)

func _set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled

    # Disable back and reset-to-defaults buttons while remapping input.
    if _input_enabled:
        _reset_to_defaults.disabled = false
        _back_button.disabled = false
    else:
        _reset_to_defaults.disabled = true
        _back_button.disabled = true

func _on_remap_started() -> void:
    _set_input_enabled(false)

    _menu_label.text = 'Press new...'

func _on_remap_finished() -> void:
    _set_input_enabled(true)

    _menu_label.text = 'Keyboard'

func _on_reset_to_defaults_pressed() -> void:
    # Clear existing mappings and reload from project settings. The keyboard
    # bindings will be reloaded from the project settings, while the controller
    # bindings will be reloaded from the current config (so as not to be
    # overwritten once we save the keyboard defaults).
    InputMap.load_from_globals()

    var keyboard_remap_buttons := [
        _jump_remap_button,
        _attack_remap_button,
        _dash_remap_button,
        _grapple_remap_button,
        _interact_remap_button,
        _heal_remap_button,
    ]

    # Save existing controller option data to restore later.
    var controller_option_data := {}
    var config: ConfigFile = Options.get_config()
    if config.has_section('controller'):
        for keyboard_remap_button in keyboard_remap_buttons:
            var action: String = keyboard_remap_button.action
            controller_option_data[action] = config.get_value('controller', action)

    # Restore keyboard option data to defaults from project settings.
    for keyboard_remap_button in keyboard_remap_buttons:
        var action: String = keyboard_remap_button.action
        for event in InputMap.get_action_list(action):
            if event is InputEventKey:
                keyboard_remap_button.remap_action_to(event)

    # Restore existing keyboard option data.
    for action in controller_option_data:
        for existing_event in InputMap.get_action_list(action):
            if existing_event is InputEventJoypadButton:
                InputMap.action_erase_event(action, existing_event)

                var new_event := InputEventJoypadButton.new()
                new_event.button_index = controller_option_data[action]
                InputMap.action_add_event(action, new_event)

func _on_back_pressed() -> void:
    go_to_previous_menu()
