extends 'res://actors/enemies/state.gd'

var _velocity := Vector2.ZERO

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    _velocity = Vector2.ZERO

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    if failure.is_on_floor():
        failure.emit_dust_puff()
        return {'new_state': SluggishFailure.State.WALK}

    var gravity := physics_manager.get_gravity()
    _velocity.y = min(
        _velocity.y + gravity * delta, physics_manager.get_terminal_velocity())
    failure.move(_velocity)

    return {'new_state': SluggishFailure.State.NO_CHANGE}
