extends 'res://actors/enemies/enemy_state.gd'

# The time spent telegraphing the bash attack by shaking in place.
const SHAKE_DURATION: float = 0.3

export(float, EASE) var damp_easing := 1.0

var _player: Player = null

onready var _shake_timer: Timer = $ShakeTimer

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().stop()

    sentry_drone.get_sound_manager().play(
        EnemySoundManager.Sounds.SENTRY_DRONE_BASH_TELEGRAPH)

    _player = Util.get_player()

    _shake_timer.one_shot = true
    _shake_timer.wait_time = SHAKE_DURATION
    _shake_timer.start()

func exit(sentry_drone: SentryDrone) -> void:
    sentry_drone.reset_sprite_position()

    sentry_drone.get_sound_manager()                                      \
        .get_player(EnemySoundManager.Sounds.SENTRY_DRONE_BASH_TELEGRAPH) \
        .stop()

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var damping := ease(
        _shake_timer.time_left / _shake_timer.wait_time, damp_easing)
    sentry_drone.shake_once(damping)

    sentry_drone.set_direction(Util.direction(sentry_drone, _player))

    if _shake_timer.is_stopped():
        # Since the player's origin is at its feet, player.global_position will
        # refer to that point, and not the center of the player sprite. Using
        # the center for distance and direction calculations ensures that e.g.
        # drones flush with the ground (such as immediately after having hit it)
        # will not immediately ram into the ground when trying to bash the
        # nearby player who is also flush with the ground.
        return {
            'new_state': SentryDrone.State.NEXT_STATE_IN_SEQUENCE,
            'direction_to_player': sentry_drone.global_position.direction_to(
                _player.get_center()),
        }

    return {'new_state': SentryDrone.State.NO_CHANGE}
