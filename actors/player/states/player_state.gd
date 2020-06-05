extends 'res://actors/shared/states/state.gd'

# Called when handling input from the player. Returns a dictionary with at least
# the new state to transition to (in the 'new_state' key). If the new state is
# NO_CHANGE, remain in current state. Can also pass additional metadata via
# other keys.
func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {}