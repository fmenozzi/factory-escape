extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    _velocity.y = 0.0

    warden.get_animation_player().play('fall')

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if warden.is_on_floor():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    # Make sure we're falling backwards.
    var physics_manager := warden.get_physics_manager()
    var speed := physics_manager.get_horizontal_backstep_speed()
    _velocity.x = speed * -warden.direction

    # Fall due to gravity.
    var gravity := physics_manager.get_backstep_gravity()
    var terminal_velocity := physics_manager.get_terminal_velocity()
    _velocity.y = min(_velocity.y + gravity * delta, terminal_velocity)

    warden.move(_velocity)

    return {'new_state': Warden.State.NO_CHANGE}
