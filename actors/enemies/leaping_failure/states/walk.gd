extends 'res://actors/enemies/state.gd'

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.get_node('AnimationPlayer').play('walk')

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    failure.move(Vector2(failure.direction * failure.SPEED, 10))

    if failure.is_on_wall():
        failure.set_direction(-1 * failure.direction)
    elif not failure.is_on_floor():
        return {'new_state': LeapingFailure.State.FALL}

    return {'new_state': LeapingFailure.State.NO_CHANGE}
