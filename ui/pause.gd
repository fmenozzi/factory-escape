extends Control
class_name Pause

onready var MENUS = {
    Menu.Menus.UNPAUSED: $MenuBackground/UnpausedState,

    Menu.Menus.PAUSE:   $MenuBackground/PauseMenu,
    Menu.Menus.OPTIONS: $MenuBackground/OptionsMenu,
    Menu.Menus.QUIT:    $MenuBackground/QuitMenu,

    Menu.Menus.AUDIO_OPTIONS:      $MenuBackground/AudioOptionsMenu,
    Menu.Menus.VIDEO_OPTIONS:      $MenuBackground/VideoOptionsMenu,
    Menu.Menus.CONTROLLER_OPTIONS: $MenuBackground/ControllerOptionsMenu,
}
var _current_menu: VBoxContainer = null

onready var _click_sound: AudioStreamPlayer = $ClickSound
onready var _black_overlay: ColorRect = $BlackOverlay

func _ready() -> void:
    # Intercept all menu_changed signals from individual submenus.
    for menu in MENUS.values():
        menu.connect('menu_changed', self, '_change_menu')
        menu.connect('menu_navigated', self, '_emit_click_sound')

    # Start in unpaused state.
    _current_menu = MENUS[Menu.Menus.UNPAUSED]
    _change_menu(Menu.Menus.UNPAUSED, Menu.Menus.UNPAUSED)

    _current_menu.connect('pause_changed', self, '_set_paused')

func _input(event: InputEvent) -> void:
    _current_menu.handle_input(event)

func _change_menu(old_menu: int, new_menu: int) -> void:
    # All inputs while paused should not be propagated out of the pause menu to
    # things like the player controller, dialog boxes, etc.
    #
    # TODO: This doesn't work when placed after the handle_input() call in the
    #       _input() method above, see if you can figure out why. The issue is
    #       that using the dpad to navigate the menu no longer works in that
    #       case.
    if get_tree().paused:
        accept_event()

    _current_menu.exit()
    _current_menu = MENUS[new_menu]
    _current_menu.enter(old_menu)

func _emit_click_sound() -> void:
    _click_sound.play()

func _set_paused(new_pause_state: bool) -> void:
    get_tree().paused = new_pause_state
    _black_overlay.visible = new_pause_state
