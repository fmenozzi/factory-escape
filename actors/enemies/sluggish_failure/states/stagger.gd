extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    var direction_from_hit: int = previous_state_dict['direction_from_hit']
    assert(direction_from_hit != null)

    failure.get_pushback_manager().start_pushback(Vector2(direction_from_hit, 1))

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    var pushback_manager := failure.get_pushback_manager()

    if not pushback_manager.is_being_pushed_back():
        return {'new_state': SluggishFailure.State.CONTRACT}

    failure.move(pushback_manager.get_pushback_velocity())

    return {'new_state': SluggishFailure.State.NO_CHANGE}
