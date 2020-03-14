extends 'res://actors/enemies/state.gd'

const BASH_SPEED: float = 16.0 * Util.TILE_SIZE

var _direction_to_player: Vector2 = Vector2.ZERO

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    assert('direction_to_player' in previous_state_dict)
    _direction_to_player = previous_state_dict['direction_to_player']
    assert(_direction_to_player != null)

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    sentry_drone.move(_direction_to_player * BASH_SPEED)

    if sentry_drone.is_colliding():
        Screenshake.start(
            Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)
        sentry_drone.move(-_direction_to_player * BASH_SPEED)
        return {'new_state': SentryDrone.State.BASH_RECOVER}

    return {'new_state': SentryDrone.State.NO_CHANGE}
