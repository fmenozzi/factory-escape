extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    _velocity.y = warden.get_physics_manager().get_max_backstep_velocity()

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    # Switch to 'fall' state once we reach apex of jump.
    if _velocity.y >= 0:
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    # Make sure we're jumping backwards.
    var physics_manager := warden.get_physics_manager()
    var speed := physics_manager.get_horizontal_backstep_speed()
    _velocity.x = speed * -warden.direction

    # Move due to gravity.
    var gravity := physics_manager.get_backstep_gravity()
    _velocity.y += gravity * delta

    # Don't snap while jumping.
    warden.move(_velocity, Util.NO_SNAP)

    return {'new_state': Warden.State.NO_CHANGE}
