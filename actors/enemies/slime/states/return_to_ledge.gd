extends 'res://actors/enemies/state.gd'

var _direction_to_ledge: int = Util.Direction.NONE

func enter(slime: Slime, previous_state_dict: Dictionary) -> void:
    _direction_to_ledge = previous_state_dict['direction_to_ledge']
    assert(_direction_to_ledge != null)

    slime.set_direction(_direction_to_ledge)

func exit(slime: Slime) -> void:
    pass

func update(slime: Slime, delta: float) -> Dictionary:
    if not slime.is_off_ledge():
        return {'new_state': Slime.State.WALK}

    slime.move(Vector2(_direction_to_ledge * slime.SPEED, 10))

    return {'new_state': Slime.State.NO_CHANGE}
