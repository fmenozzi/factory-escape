extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    _velocity = Vector2.ZERO

    warden.get_animation_player().play('intro_fall')

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if warden.is_on_floor():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    var physics_manager := warden.get_physics_manager()
    var gravity := physics_manager.get_gravity()
    _velocity.y = min(
        _velocity.y + gravity * delta, physics_manager.get_terminal_velocity())
    warden.move(_velocity)

    return {'new_state': Warden.State.NO_CHANGE}
