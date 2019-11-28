extends Node

# Called when the player enters this state. The metadata data of the previous
# state is also passed in.
func enter(player: Player, previous_state_dict: Dictionary) -> void:
    pass

# Called when the player exits this state.
func exit(player: Player) -> void:
    pass

# Called when handling input from the player.
#
# Returns a dictionary with at least the new state to transition to (in the
# 'new_state' key). If the new state is NO_CHANGE, remain in current state. Can
# also pass additional metadata via other keys.
func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {}

# Called on every frame.
#
# Returns a dictionary with at least the new state to transition to (in the
# 'new_state' key). If the new state is NO_CHANGE, remain in current state. Can
# also pass additional metadata via other keys.
func update(player: Player, delta: float) -> Dictionary:
    return {}