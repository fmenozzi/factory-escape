extends 'res://actors/enemies/enemy_state.gd'

# The minimum number of seconds the drone waits while idling before turning
# around. A small random value will be added to this to create the final timer
# duration in order to avoid having all the drones turn around at the same time.
const MIN_TURN_AROUND_PERIOD: float = 2.0

onready var _timer: Timer = $TurnAroundDurationTimer

func _ready() -> void:
    _timer.one_shot = false
    _timer.wait_time = MIN_TURN_AROUND_PERIOD + rand_range(0.0, 1.0)

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('idle')

    _timer.connect('timeout', self, '_on_turn_around_timeout', [sentry_drone])
    _timer.start()

func exit(sentry_drone: RangedSentryDrone) -> void:
    _timer.stop()

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': RangedSentryDrone.State.ALERTED}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}

func _on_turn_around_timeout(sentry_drone: RangedSentryDrone) -> void:
    sentry_drone.set_direction(-1 * sentry_drone.direction)
