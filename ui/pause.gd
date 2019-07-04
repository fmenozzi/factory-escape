extends Control
class_name Pause

# The possible menus that the player can navigate to after pressing the pause
# button. Starts in the UNPAUSED state.
#
# TODO: Consider changing this back to "State", rather than "Menu", given that
#       UNPAUSED isn't a menu.
enum Menu {
    # Reserved for representing the unpaused state, in order to know when to
    # toggle visibility of the main pause menu and actually pause the game.
    UNPAUSED,

    PAUSE,
    OPTIONS,
    QUIT,

    VIDEO_OPTIONS,
    CONTROLLER_OPTIONS,
}

onready var MENUS = {
    Menu.UNPAUSED: $MenuBackground/UnpausedState,

    Menu.PAUSE:   $MenuBackground/PauseMenu,
    Menu.OPTIONS: $MenuBackground/OptionsMenu,
    Menu.QUIT:    $MenuBackground/QuitMenu,

    Menu.VIDEO_OPTIONS:      $MenuBackground/VideoOptionsMenu,
    Menu.CONTROLLER_OPTIONS: $MenuBackground/ControllerOptionsMenu,
}
var _current_menu: VBoxContainer = null

onready var _black_overlay: ColorRect = $BlackOverlay

func _ready() -> void:
    # Intercept all menu_changed signals from individual submenus.
    for menu in MENUS.values():
        menu.connect('menu_changed', self, '_change_menu')

    # Start in unpaused state.
    _current_menu = MENUS[Menu.UNPAUSED]
    _change_menu(Menu.UNPAUSED, Menu.UNPAUSED)

func _input(event: InputEvent) -> void:
    _current_menu.handle_input(self, event)

func _change_menu(old_menu: int, new_menu: int) -> void:
    _current_menu.exit(self)
    _current_menu = MENUS[new_menu]
    _current_menu.enter(self, old_menu)

func _set_paused(new_pause_state: bool) -> void:
    get_tree().paused = new_pause_state
    _black_overlay.visible = new_pause_state
