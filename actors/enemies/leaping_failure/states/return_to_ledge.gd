extends 'res://actors/enemies/state.gd'

var _direction_to_ledge: int = Util.Direction.NONE

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _direction_to_ledge = previous_state_dict['direction_to_ledge']
    assert(_direction_to_ledge != null)

    failure.set_direction(_direction_to_ledge)

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if not failure.is_off_ledge():
        return {'new_state': LeapingFailure.State.WALK}

    failure.move(Vector2(_direction_to_ledge * failure.SPEED, 10))

    return {'new_state': LeapingFailure.State.NO_CHANGE}
