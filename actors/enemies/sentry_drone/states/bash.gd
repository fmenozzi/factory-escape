extends 'res://actors/enemies/enemy_state.gd'

# The maximum distance the sentry drone will continue to travel once it misses
# the player.
const MAX_BASH_MISS_DISTANCE: float = 4.0 * Util.TILE_SIZE

var _direction_to_player: Vector2 = Vector2.ZERO
var _player: Player
var _bash_miss_distance_travelled := 0.0

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    assert('direction_to_player' in previous_state_dict)
    _direction_to_player = previous_state_dict['direction_to_player']
    assert(_direction_to_player != null)

    _player = Util.get_player()
    _bash_miss_distance_travelled = 0.0

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var physics_manager := sentry_drone.get_physics_manager()
    var bash_speed := physics_manager.get_bash_speed()

    sentry_drone.move(_direction_to_player * physics_manager.get_bash_speed())

    if _drone_missed_player(sentry_drone):
        _bash_miss_distance_travelled += bash_speed * delta
        if _bash_miss_distance_travelled > MAX_BASH_MISS_DISTANCE:
            return {'new_state': SentryDrone.State.NEXT_STATE_IN_SEQUENCE}

    if sentry_drone.is_colliding():
        Screenshake.start(
            Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)
        for i in sentry_drone.get_slide_count():
            # Emit dust puff at all collision positions.
            var collision := sentry_drone.get_slide_collision(i)
            Effects.spawn_dust_puff_at(collision.position)
        sentry_drone.move(-_direction_to_player * bash_speed)
        return {'new_state': SentryDrone.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': SentryDrone.State.NO_CHANGE}

func _drone_missed_player(sentry_drone: SentryDrone) -> bool:
    var original_direction := _direction_to_player
    var current_direction := sentry_drone.global_position.direction_to(_player.get_center())

    return original_direction.dot(current_direction) < 0
