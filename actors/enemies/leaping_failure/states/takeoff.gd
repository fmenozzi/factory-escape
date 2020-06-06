extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play('jump')

    failure.set_direction(Util.direction(failure, Util.get_player()))

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if not failure.get_animation_player().is_playing():
        return {'new_state': LeapingFailure.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': LeapingFailure.State.NO_CHANGE}
