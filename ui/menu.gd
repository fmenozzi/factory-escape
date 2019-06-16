extends VBoxContainer

signal menu_changed(old_menu, new_menu)

# Called when this menu is entered.
func enter(pause_node) -> void:
	pass

# Called when this menu is exited.
func exit(pause_node) -> void:
	pass

# Called when handling input for this menu.
func handle_input(pause_node, event: InputEvent):
	pass