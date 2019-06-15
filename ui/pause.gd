extends Control

signal menu_changed(new_menu)

# The possible menus that the player can navigate to after pressing the pause
# button. Starts in the PAUSE menu. NO_CHANGE is reserved for menus to indicate
# that the current menu should not be changed. PREVIOUS is reserved for menus to
# indicate that the current menu should transition to the previous menu.
enum Menu {
	NO_CHANGE,
	PREVIOUS,
	PAUSE,
	OPTIONS,
	QUIT,
}
var _current_menu = null

onready var MENUS = {
	Menu.PAUSE:   $MenuBackground/PauseMenu,
	Menu.OPTIONS: $MenuBackground/OptionsMenu,
	Menu.QUIT:    $MenuBackground/QuitMenu,
}

func _ready() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_pause'):
		_toggle_pause()
		
		_current_menu = MENUS[Menu.PAUSE]
		_change_menu(Menu.PAUSE)
		
func _change_menu(new_menu: int) -> void:
	_current_menu.exit(self)
	_current_menu = MENUS[new_menu]
	_current_menu.enter(self)
	
	emit_signal('menu_changed', _current_menu.get_name())
	
func _toggle_pause() -> void:
	var new_pause_state := not get_tree().paused
	get_tree().paused = new_pause_state
	self.visible = new_pause_state
