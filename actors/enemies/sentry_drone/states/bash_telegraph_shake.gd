extends 'res://actors/enemies/state.gd'

# The time spent telegraphing the bash attack by shaking in place.
const SHAKE_DURATION: float = 0.5

export(float, EASE) var damp_easing := 1.0

var _sentry_drone_sprite: Sprite = null
var _player: Player = null

onready var _shake_timer: Timer = $ShakeTimer

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().stop()

    _sentry_drone_sprite = sentry_drone.get_node('Sprite')

    _player = Util.get_player()

    _shake_timer.one_shot = true
    _shake_timer.wait_time = SHAKE_DURATION
    _shake_timer.start()

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    _shake_once()

    sentry_drone.set_direction(Util.direction(sentry_drone, _player))

    if _shake_timer.is_stopped():
        # Since the player's origin is at its feet, player.global_position will
        # refer to that point, and not the center of the player sprite. Using
        # the center for distance and direction calculations ensures that e.g.
        # drones flush with the ground (such as immediately after having hit it)
        # will not immediately ram into the ground when trying to bash the
        # nearby player who is also flush with the ground.
        _sentry_drone_sprite.position = Vector2.ZERO
        return {
            'new_state': SentryDrone.State.BASH_TELEGRAPH_PAUSE,
            'direction_to_player': sentry_drone.global_position.direction_to(
                _player.get_center()),
        }

    return {'new_state': SentryDrone.State.NO_CHANGE}

# Offset the sprite's position from the sentry drone itself, similar to how
# screenshake is implemented.
func _shake_once() -> void:
    var damping := ease(
        _shake_timer.time_left / _shake_timer.wait_time, damp_easing)

    _sentry_drone_sprite.position = Vector2(
        damping * rand_range(-1.0, 1.0),
        damping * rand_range(-1.0, 1.0))
