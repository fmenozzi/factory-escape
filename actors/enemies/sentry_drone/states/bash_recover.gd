extends 'res://actors/enemies/state.gd'

const RECOVER_DURATION: float = 1.0
const SHAKE_DURATION: float = RECOVER_DURATION / 3.0

export(float, EASE) var damp_easing := 1.0

# Use separate timers for the entire recovery duration and the portion of the
# recovery spent shaking slightly (as a result of the impact).
onready var _recover_timer: Timer = $RecoverTimer
onready var _shake_timer: Timer = $ShakeTimer

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    _recover_timer.one_shot = true
    _recover_timer.wait_time = RECOVER_DURATION
    _recover_timer.start()

    _shake_timer.one_shot = true
    _shake_timer.wait_time = SHAKE_DURATION
    _shake_timer.start()

func exit(sentry_drone: SentryDrone) -> void:
    sentry_drone.reset_sprite_position()

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    sentry_drone.shake_once(_get_damping())

    if _recover_timer.is_stopped():
        return {'new_state': SentryDrone.State.IDLE}

    return {'new_state': SentryDrone.State.NO_CHANGE}

func _get_damping() -> float:
    return ease(
        _shake_timer.time_left / _shake_timer.wait_time,
        damp_easing)
