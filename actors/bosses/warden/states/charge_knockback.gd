extends 'res://actors/enemies/enemy_state.gd'

const KNOCKBACK_SPEED := 10.0 * Util.TILE_SIZE

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('charge_knockback')

    Screenshake.start(Screenshake.Duration.MEDIUM, Screenshake.Amplitude.SMALL)
    Rumble.start(Rumble.Type.WEAK, 0.3)

    _velocity = KNOCKBACK_SPEED * Vector2(-warden.direction, -1).normalized()

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    var physics_manager := warden.get_physics_manager()

    # Apply gravity with terminal velocity. Don't snap during knockback.
    _velocity.y = min(
        _velocity.y + physics_manager.get_gravity() * delta,
        physics_manager.get_terminal_velocity())
    warden.move(_velocity, Util.NO_SNAP)

    if warden.is_on_floor():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
