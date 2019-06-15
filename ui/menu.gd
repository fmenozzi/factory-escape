extends VBoxContainer

# Called when this menu is entered.
func enter(pause_node) -> void:
	pass
	
# Called when this menu is exited.
func exit(pause_node) -> void:
	pass
	
# Called when handling input for this menu. Returns the new menu to transition
# to, NO_CHANGE if remaining in current menu, or PREVIOUS if navigating back to
# the previous menu.
#
# TODO: Consider changing this (and potentially the player state machine too) to
#       a signals-based approach, rather than having to constantly return
#       NO_CHANGE and having to do so in this function (as opposed to using a
#       signals-based approach where you can change state from within e.g. a
#       button callback).
func handle_input(pause_node, event: InputEvent) -> int:
	return -1