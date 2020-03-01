extends 'res://actors/enemies/state.gd'

# The time spent pausing before initiating the bash attack.
const PAUSE_DURATION: float = 0.5

onready var _pause_timer: Timer = $PauseTimer

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    _pause_timer.one_shot = true
    _pause_timer.wait_time = PAUSE_DURATION
    _pause_timer.start()

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    if _pause_timer.is_stopped():
        return {'new_state': SentryDrone.State.IDLE}

    return {'new_state': SentryDrone.State.NO_CHANGE}
