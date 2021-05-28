extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    var physics_manager := failure.get_physics_manager()

    _velocity.y = physics_manager.get_max_jump_velocity()

    failure.emit_dust_puff()

    failure.get_sound_manager().play(LeapingFailureSoundManager.Sounds.JUMP)

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    # Switch to 'fall' state once we reach apex of jump.
    if _velocity.y >= 0:
        return {
            'new_state': LeapingFailure.State.NEXT_STATE_IN_SEQUENCE,
            'aggro': true,
        }

    var speed := physics_manager.get_horizontal_jump_speed()
    _velocity.x = speed * failure.direction

    # Move due to gravity.
    var gravity := physics_manager.get_gravity()
    _velocity.y += gravity * delta

    # Don't snap while jumping.
    failure.move(_velocity, Util.NO_SNAP)

    return {'new_state': LeapingFailure.State.NO_CHANGE}
