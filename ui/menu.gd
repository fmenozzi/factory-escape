extends VBoxContainer

signal menu_changed(new_menu)

# Called when this menu is entered.
func enter(pause_node) -> void:
	pass

# Called when this menu is exited.
func exit(pause_node) -> void:
	pass

# Called when handling input for this menu. Returns the new menu to transition
# to or NO_CHANGE if remaining in current menu. By default, pressing pause will
# return to the unpaused state.
func handle_input(pause_node, event: InputEvent) -> int:
	if event.is_action_pressed('ui_pause'):
		return pause_node.Menu.UNPAUSED
	return pause_node.Menu.NO_CHANGE