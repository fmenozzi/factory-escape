extends 'res://actors/enemies/enemy_state.gd'

var _direction_to_ledge: int = Util.Direction.NONE

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    _direction_to_ledge = previous_state_dict['direction_to_ledge']
    assert(_direction_to_ledge != null)

    failure.set_direction(_direction_to_ledge)

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    if not failure.is_off_ledge():
        return {'new_state': SluggishFailure.State.WALK}

    failure.move(
        Vector2(_direction_to_ledge * physics_manager.get_movement_speed(), 10))

    return {'new_state': SluggishFailure.State.NO_CHANGE}
