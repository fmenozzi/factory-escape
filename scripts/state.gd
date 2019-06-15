extends Node

# Called when host enters this state.
func enter(host) -> void:
	pass

# Called when host exits this state.
func exit(host) -> void:
	pass

# Called when handling input from the host.
#
# Returns the new state to transition to or NO_CHANGE if remaining in current
# state.
func handle_input(host, event: InputEvent) -> int:
	return -1

# Called on every frame.
#
# Returns the new state to transition to or NO_CHANGE if remaining in current
# state.
func update(host, delta: float) -> int:
	return -1