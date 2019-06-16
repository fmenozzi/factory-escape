extends Control

# The possible menus that the player can navigate to after pressing the pause
# button. Starts in the UNPAUSED state.
#
# TODO: Consider changing this back to "State", rather than "Menu", given that
#       UNPAUSED isn't a menu.
enum Menu {
	# Reserved for menus to indicate that the current menu should not be
	# changed.
	NO_CHANGE,

	# Reserved for representing the unpaused state, in order to know when to
	# toggle visibility of the main pause menu and actually pause the game.
	UNPAUSED,

	PAUSE,
	OPTIONS,
	QUIT,
}

onready var MENUS = {
	Menu.UNPAUSED: $MenuBackground/UnpausedState,

	Menu.PAUSE:    $MenuBackground/PauseMenu,
	Menu.OPTIONS:  $MenuBackground/OptionsMenu,
	Menu.QUIT:     $MenuBackground/QuitMenu,
}
var _current_menu = null

onready var _black_overlay: ColorRect = $BlackOverlay

# TODO: Ensure that we return focus appropriately when navigating back to
#       previous menus (e.g. when you hit "No" in the quit menu and return to
#       the pause menu, "Quit" should have focus and not "Resume"). The use of
#       pushdown automata might help with this.

func _ready() -> void:
	# Allow for button callbacks within individual menus to call _change_menu().
	for menu in MENUS.values():
		menu.connect('menu_changed', self, '_change_menu')

	# Start in unpaused state.
	_current_menu = MENUS[Menu.UNPAUSED]
	_change_menu(Menu.UNPAUSED)

func _input(event: InputEvent) -> void:
	_change_menu(_current_menu.handle_input(self, event))

func _change_menu(new_menu: int) -> void:
	if new_menu == Menu.NO_CHANGE:
		return

	_current_menu.exit(self)
	_current_menu = MENUS[new_menu]
	_current_menu.enter(self)

func _set_paused(new_pause_state: bool) -> void:
	get_tree().paused = new_pause_state
	_black_overlay.visible = new_pause_state
