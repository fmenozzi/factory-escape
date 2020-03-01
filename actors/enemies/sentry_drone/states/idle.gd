extends 'res://actors/enemies/state.gd'

var _player: Player = null

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('idle')

    _player = Util.get_player()

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var distance_to_player := sentry_drone.global_position.distance_to(
        _player.global_position)
    if distance_to_player <= 4.0 * Util.TILE_SIZE:
        return {'new_state': SentryDrone.State.BASH_TELEGRAPH_SHAKE}

    return {'new_state': SentryDrone.State.NO_CHANGE}
