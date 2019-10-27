extends Node

# Called when host enters this state. The metadata data of the previous state is
# also passed in.
func enter(host, previous_state_dict: Dictionary) -> void:
    pass

# Called when host exits this state.
func exit(host) -> void:
    pass

# Called when handling input from the host.
#
# Returns a dictionary with at least the new state to transition to (in the
# 'new_state' key). If the new state is NO_CHANGE, remain in current state. Can
# also pass additional metadata via other keys.
func handle_input(host, event: InputEvent) -> Dictionary:
    return {}

# Called on every frame.
#
# Returns a dictionary with at least the new state to transition to (in the
# 'new_state' key). If the new state is NO_CHANGE, remain in current state. Can
# also pass additional metadata via other keys.
func update(host, delta: float) -> Dictionary:
    return {}