extends Node

# Called when enemy enters this state. The metadata data of the previous state
# is also passed in.
func enter(enemy, previous_state_dict: Dictionary) -> void:
    pass

# Called when enemy exits this state.
func exit(enemy) -> void:
    pass

# Called on every frame.
#
# Returns a dictionary with at least the new state to transition to (in the
# 'new_state' key). If the new state is NO_CHANGE, remain in current state. Can
# also pass additional metadata via other keys.
func update(enemy, delta: float) -> Dictionary:
    return {}
