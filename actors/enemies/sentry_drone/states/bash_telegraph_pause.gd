extends 'res://actors/enemies/enemy_state.gd'

# The time spent pausing before initiating the bash attack.
const PAUSE_DURATION: float = 0.3

var _direction_to_player: Vector2 = Vector2.ZERO

onready var _pause_timer: Timer = $PauseTimer

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    assert('direction_to_player' in previous_state_dict)
    _direction_to_player = previous_state_dict['direction_to_player']
    assert(_direction_to_player != null)

    _pause_timer.one_shot = true
    _pause_timer.wait_time = PAUSE_DURATION
    _pause_timer.start()

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    if _pause_timer.is_stopped():
        return {
            'new_state': SentryDrone.State.NEXT_STATE_IN_SEQUENCE,
            'direction_to_player': _direction_to_player,
        }

    return {'new_state': SentryDrone.State.NO_CHANGE}
