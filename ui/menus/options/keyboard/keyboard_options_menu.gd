extends 'res://ui/menus/menu.gd'

const SECTION := 'keyboard'

onready var _jump_remap_button: Button = $JumpRemapContainer/KeyboardRemapButton
onready var _attack_remap_button: Button = $AttackRemapContainer/KeyboardRemapButton
onready var _dash_remap_button: Button = $DashRemapContainer/KeyboardRemapButton
onready var _grapple_remap_button: Button = $GrappleRemapContainer/KeyboardRemapButton
onready var _interact_remap_button: Button = $InteractRemapContainer/KeyboardRemapButton

onready var _back_button: Button = $Back

var _input_enabled := true

func _ready() -> void:
    for remap_button in get_tree().get_nodes_in_group('keyboard_remap_button'):
        remap_button.connect('remap_started', self, '_on_remap_started')
        remap_button.connect('remap_finished', self, '_on_remap_started')

    _back_button.connect('pressed', self, '_on_back_pressed')

func enter(previous_menu: int) -> void:
    _jump_remap_button.grab_focus()
    _set_input_enabled(true)

    self.visible = true

func exit() -> void:
    self.visible = false

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
    }]

func load_options_data(config: ConfigFile) -> void:
    if config.has_section_key(SECTION, 'player_jump'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_jump')
        assert(_jump_remap_button.remap_action_to(event))

    if config.has_section_key(SECTION, 'player_attack'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_attack')
        assert(_attack_remap_button.remap_action_to(event))

    if config.has_section_key(SECTION, 'player_dash'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_dash')
        assert(_dash_remap_button.remap_action_to(event))

    if config.has_section_key(SECTION, 'player_grapple'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_grapple')
        assert(_grapple_remap_button.remap_action_to(event))

    if config.has_section_key(SECTION, 'player_interact'):
        var event := InputEventKey.new()
        event.scancode = config.get_value(SECTION, 'player_interact')
        assert(_interact_remap_button.remap_action_to(event))

func _set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled

func _on_remap_started() -> void:
    _set_input_enabled(false)

func _on_remap_finished() -> void:
    _set_input_enabled(true)
    Options.save_options()

func _on_back_pressed() -> void:
    go_to_previous_menu()
