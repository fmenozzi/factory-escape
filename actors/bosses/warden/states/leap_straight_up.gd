extends 'res://actors/enemies/enemy_state.gd'

const GRAVITY_MULTIPLIER := 1.5

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    _velocity.y = warden.get_physics_manager().get_max_jump_velocity()

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    # Move due to gravity.
    var gravity := warden.get_physics_manager().get_gravity()
    _velocity.y += GRAVITY_MULTIPLIER * gravity * delta

    # Don't snap while jumping.
    warden.move(_velocity, Util.NO_SNAP)

    if warden.is_on_floor():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
