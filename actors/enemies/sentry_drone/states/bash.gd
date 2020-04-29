extends 'res://actors/enemies/state.gd'

var _direction_to_player: Vector2 = Vector2.ZERO

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    assert('direction_to_player' in previous_state_dict)
    _direction_to_player = previous_state_dict['direction_to_player']
    assert(_direction_to_player != null)

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var physics_manager := sentry_drone.get_physics_manager()
    var bash_speed := physics_manager.get_bash_speed()

    sentry_drone.move(_direction_to_player * physics_manager.get_bash_speed())

    if sentry_drone.is_colliding():
        Screenshake.start(
            Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)
        # TODO: Maybe try to emit puff at contact point.
        sentry_drone.emit_dust_puff()
        sentry_drone.move(-_direction_to_player * bash_speed)
        return {'new_state': SentryDrone.State.BASH_RECOVER}

    return {'new_state': SentryDrone.State.NO_CHANGE}
