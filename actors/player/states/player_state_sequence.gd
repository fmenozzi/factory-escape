extends 'res://actors/shared/states/state_sequence.gd'

# Called when handling input from the player. Returns a dictionary with at least
# the new state to transition to (in the 'new_state' key). If the new state is
# NO_CHANGE, remain in current state. Can also return additional metadata via
# other keys.
func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}
