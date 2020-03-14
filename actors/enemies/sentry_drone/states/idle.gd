extends 'res://actors/enemies/state.gd'

const AGGRO_RADIUS := 4.0 * Util.TILE_SIZE

var _player: Player = null

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('idle')

    _player = Util.get_player()

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var distance_to_player := sentry_drone.global_position.distance_to(
        _player.get_center())
    if distance_to_player <= AGGRO_RADIUS:
        return {'new_state': SentryDrone.State.BASH_TELEGRAPH_SHAKE}

    return {'new_state': SentryDrone.State.NO_CHANGE}
