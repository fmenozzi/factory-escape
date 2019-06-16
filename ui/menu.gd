extends VBoxContainer

signal menu_changed(old_menu, new_menu)

# Called when this menu is entered.
func enter(pause: Pause) -> void:
	pass

# Called when this menu is exited.
func exit(pause: Pause) -> void:
	pass

# Called when handling input for this menu.
func handle_input(pause: Pause, event: InputEvent):
	pass