extends 'res://actors/enemies/state.gd'

const AGGRO_RADIUS := 4.0 * Util.TILE_SIZE

var _player: Player = null
var _obstacle_detector: RayCast2D = null

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('idle')

    _player = Util.get_player()
    _obstacle_detector = sentry_drone.get_obstacle_detector()

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var distance_to_player := sentry_drone.global_position.distance_to(
        _player.get_center())

    _obstacle_detector.cast_to = _obstacle_detector.to_local(
        _player.get_center())
    var player_in_line_of_sight := not _obstacle_detector.is_colliding()

    if distance_to_player <= AGGRO_RADIUS and player_in_line_of_sight:
        return {'new_state': SentryDrone.State.BASH_TELEGRAPH_SHAKE}

    return {'new_state': SentryDrone.State.NO_CHANGE}
