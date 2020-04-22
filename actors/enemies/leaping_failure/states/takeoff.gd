extends 'res://actors/enemies/state.gd'

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play('jump')

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if not failure.get_animation_player().is_playing():
        return {'new_state': LeapingFailure.State.JUMP}

    return {'new_state': LeapingFailure.State.NO_CHANGE}
