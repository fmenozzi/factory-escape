extends 'res://actors/enemies/state.gd'

const ALERTED_DURATION: float = 0.25

var _player: Player = null

onready var _timer: Timer = $AlertedDurationTimer

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = ALERTED_DURATION

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    sentry_drone.get_animation_player().stop(false)

    # Display alerted reaction.
    sentry_drone.get_react_sprite().change_state(ReactSprite.State.ALERTED)

    # Turn to face player when alerted.
    sentry_drone.set_direction(Util.direction(sentry_drone, _player))

    # Start duration timer.
    _timer.start()

func exit(sentry_drone: SentryDrone) -> void:
    # Hide reaction sprite.
    sentry_drone.get_react_sprite().change_state(ReactSprite.State.NONE)

    # Stop duration timer.
    _timer.stop()

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    if _timer.is_stopped():
        return {'new_state': SentryDrone.State.BASH_TELEGRAPH_SHAKE}

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_aggro_range() or aggro_manager.can_see_player()):
        return {'new_state': SentryDrone.State.UNALERTED}

    return {'new_state': SentryDrone.State.NO_CHANGE}
