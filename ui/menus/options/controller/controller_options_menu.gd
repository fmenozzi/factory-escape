extends 'res://ui/menus/menu.gd'

onready var _jump_button: Button = $Jump/Jump
onready var _attack_button: Button = $Attack/Attack
onready var _dash_button: Button = $Dash/Dash
onready var _grapple_button: Button = $Grapple/Grapple
onready var _interact_button: Button = $Interact/Interact

onready var _back_button: Button = $Back

enum PlayerAction {
    JUMP,
    ATTACK,
    DASH,
    GRAPPLE,
    INTERACT,
}

onready var PLAYER_ACTION_DATA: Dictionary = {
    PlayerAction.JUMP: {
        'ui_button':         _jump_button,
        'ui_texture_button': $Jump/JumpButtonTexture,
        'ui_button_text':    'Jump',
        'input_action':      'player_jump',
    },
    PlayerAction.ATTACK: {
        'ui_button':         _attack_button,
        'ui_texture_button': $Attack/AttackButtonTexture,
        'ui_button_text':    'Attack',
        'input_action':      'player_attack',
    },
    PlayerAction.DASH: {
        'ui_button':         _dash_button,
        'ui_texture_button': $Dash/DashButtonTexture,
        'ui_button_text':    'Dash',
        'input_action':      'player_dash',
    },
    PlayerAction.GRAPPLE: {
        'ui_button':         _grapple_button,
        'ui_texture_button': $Grapple/GrappleButtonTexture,
        'ui_button_text':    'Grapple',
        'input_action':      'player_grapple',
    },
    PlayerAction.INTERACT: {
        'ui_button':         _interact_button,
        'ui_texture_button': $Interact/InteractButtonTexture,
        'ui_button_text':    'Interact',
        'input_action':      'player_interact',
    },
}

# Used to keep track of when input events correspond to navigating the menu vs
# actually remapping the controls.
var _is_remapping: bool = false

# UI button corresponding to the control that we want to remap.
var _player_action_to_remap: int = -1

const JOYPAD_BUTTONS_TO_TEXTURES: Dictionary = {
    # Main buttons.
    JOY_XBOX_A: preload('res://ui/menus/options/controller/textures/xbox-a.png'),
    JOY_XBOX_B: preload('res://ui/menus/options/controller/textures/xbox-b.png'),
    JOY_XBOX_X: preload('res://ui/menus/options/controller/textures/xbox-x.png'),
    JOY_XBOX_Y: preload('res://ui/menus/options/controller/textures/xbox-y.png'),

    # Bumbers and triggers.
    JOY_L:  preload('res://ui/menus/options/controller/textures/xbox-lb.png'),
    JOY_R:  preload('res://ui/menus/options/controller/textures/xbox-rb.png'),
    JOY_L2: preload('res://ui/menus/options/controller/textures/xbox-lt.png'),
    JOY_R2: preload('res://ui/menus/options/controller/textures/xbox-rt.png'),

    # D-pad.
    JOY_DPAD_UP:    preload('res://ui/menus/options/controller/textures/xbox-dpad-up.png'),
    JOY_DPAD_RIGHT: preload('res://ui/menus/options/controller/textures/xbox-dpad-right.png'),
    JOY_DPAD_DOWN:  preload('res://ui/menus/options/controller/textures/xbox-dpad-down.png'),
    JOY_DPAD_LEFT:  preload('res://ui/menus/options/controller/textures/xbox-dpad-left.png'),
}

func enter(pause: Pause, previous_menu: int) -> void:
    self.visible = true

    _jump_button.connect('pressed', self, '_on_jump_pressed')
    _attack_button.connect('pressed', self, '_on_attack_pressed')
    _dash_button.connect('pressed', self, '_on_dash_pressed')
    _grapple_button.connect('pressed', self, '_on_grapple_pressed')
    _interact_button.connect('pressed', self, '_on_interact_pressed')

    _back_button.connect('pressed', self, '_on_back_pressed', [pause])

    _jump_button.grab_focus()

func exit(pause: Pause) -> void:
    self.visible = false

func handle_input(pause: Pause, event: InputEvent) -> void:
    if _is_remapping and event is InputEventJoypadButton:
        remap(event)
        _is_remapping = false
    else:
        if event.is_action_pressed('ui_pause'):
            change_menu(pause.Menu.CONTROLLER_OPTIONS, pause.Menu.UNPAUSED)
        elif event.is_action_pressed('ui_cancel'):
            change_menu(pause.Menu.CONTROLLER_OPTIONS, pause.Menu.OPTIONS)

        if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
            emit_menu_navigation_sound()

func setup_remap(player_action: int) -> void:
    # Change button text.
    var ui_button = PLAYER_ACTION_DATA[player_action]['ui_button']
    ui_button.set_text('Press new...')

    # TODO: Maybe yield on some kind of input signal so that we can do the
    #       remapping here and don't have to maintain a separate _is_remapping
    #       state and handle remapping in handle_input().

    _is_remapping = true
    _player_action_to_remap = player_action

# TODO: Have this persist somewhere.
func remap(event: InputEventJoypadButton) -> void:
    # Consume input event so that it doesn't get interpreted as e.g. a
    # button click/press immediately afterwards.
    get_tree().set_input_as_handled()

    var current_action_data = PLAYER_ACTION_DATA[_player_action_to_remap]

    # Make sure the desired remapping is allowed.
    var button_index = event.get_button_index()
    if not JOYPAD_BUTTONS_TO_TEXTURES.has(button_index):
        # Reset UI button text.
        var ui_button = current_action_data['ui_button']
        ui_button.set_text(current_action_data['ui_button_text'])

        return

    # Remove previous mappings and add the new one.
    #
    # TODO: Also remove previous mappings in other buttons if they match the
    #       new one. InputMap.get_action_list(action: String) could be useful
    #       for this.
    #
    # TODO: Maybe allow two mappings at once instead of just one?
    var action = current_action_data['input_action']
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, event)

    # Set new texture.
    var texture_button = current_action_data['ui_texture_button']
    texture_button.set_texture(JOYPAD_BUTTONS_TO_TEXTURES[button_index])

    # Reset UI button text.
    var ui_button = current_action_data['ui_button']
    ui_button.set_text(current_action_data['ui_button_text'])

func _on_jump_pressed() -> void:
    setup_remap(PlayerAction.JUMP)

func _on_attack_pressed() -> void:
    setup_remap(PlayerAction.ATTACK)

func _on_dash_pressed() -> void:
    setup_remap(PlayerAction.DASH)

func _on_grapple_pressed() -> void:
    setup_remap(PlayerAction.GRAPPLE)

func _on_interact_pressed() -> void:
    setup_remap(PlayerAction.INTERACT)

func _on_back_pressed(pause: Pause) -> void:
    change_menu(pause.Menu.CONTROLLER_OPTIONS, pause.Menu.OPTIONS)
