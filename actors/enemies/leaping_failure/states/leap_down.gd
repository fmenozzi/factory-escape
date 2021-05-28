extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _velocity.y = 0.0

    failure.get_animation_player().play('fall')

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    if failure.is_on_floor():
        failure.emit_dust_puff()
        failure.get_sound_manager().play(LeapingFailureSoundManager.Sounds.LAND)
        return {'new_state': LeapingFailure.State.CONTRACT_FAST}

    var speed := physics_manager.get_horizontal_jump_speed()
    _velocity.x = speed * failure.direction

    # Fall due to gravity.
    var gravity := physics_manager.get_gravity()
    var terminal_velocity := physics_manager.get_terminal_velocity()
    _velocity.y = min(_velocity.y + gravity * delta, terminal_velocity)

    failure.move(_velocity)

    return {'new_state': LeapingFailure.State.NO_CHANGE}
