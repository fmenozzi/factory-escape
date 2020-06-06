extends 'res://actors/shared/states/state_sequence.gd'

# Called when handling input from the player. Returns a dictionary with at least
# the new state to transition to (in the 'new_state' key). If the new state is
# NO_CHANGE, remain in current state. Can also return additional metadata via
# other keys.
func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var new_state_dict: Dictionary = _active_state.handle_input(player, event)
    if new_state_dict['new_state'] != player.State.NO_CHANGE:
        _active_state.exit(player)

        var new_state_index := _active_state.get_index() + 1
        if new_state_index >= get_child_count():
            # Once we finish with the last state in the sequence, transition to
            # that state's next state.
            emit_signal('sequence_finished')
            return new_state_dict

        _merge_initial_metadata(new_state_dict)

        # Before passing along the new_state_dict to the new state (since we
        # want any additional metadata keys passed too), rename the 'new_state'
        # key to 'previous_state'. It's important that we do this AFTER
        # potentially returning the new state dict back to the state sequence,
        # since we need the new_state key for that.
        new_state_dict['previous_state'] = new_state_dict['new_state']
        new_state_dict.erase('new_state')

        _active_state = get_child(new_state_index)
        _active_state.enter(player, new_state_dict)

    return {'new_state': player.State.NO_CHANGE}
