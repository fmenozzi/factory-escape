extends 'res://actors/enemies/state.gd'

const UNALERTED_DURATION: float = 2.0

var _player: Player = null

onready var _unalerted_duration_timer: Timer = $UnalertedDurationTimer
onready var _turn_around_duration_timer: Timer = $TurnAroundDurationTimer

func _ready() -> void:
    _unalerted_duration_timer.one_shot = true
    _unalerted_duration_timer.wait_time = UNALERTED_DURATION

    _turn_around_duration_timer.one_shot = false
    _turn_around_duration_timer.wait_time = UNALERTED_DURATION / 2.0

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    # Pause current animation.
    failure.get_animation_player().stop(false)

    # Display unalerted reaction.
    failure.get_react_sprite().change_state(ReactSprite.State.UNALERTED)

    # Start timers.
    _turn_around_duration_timer.connect(
        'timeout', self, '_on_turn_around_timeout', [failure])
    _unalerted_duration_timer.start()
    _turn_around_duration_timer.start()

    _player = Util.get_player()

func exit(failure: LeapingFailure) -> void:
    # Hide reaction sprite.
    failure.get_react_sprite().change_state(ReactSprite.State.NONE)

    # Stop timers.
    _unalerted_duration_timer.stop()
    _turn_around_duration_timer.stop()

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    # Transition back to alerted once back in aggro radius.
    if failure.is_in_range(_player, failure.AGGRO_RADIUS):
        return {'new_state': LeapingFailure.State.ALERTED}

    # Transition back to walk once out of "unaggro" radius.
    if _unalerted_duration_timer.is_stopped():
        if not failure.is_in_range(_player, failure.UNAGGRO_RADIUS):
            return {'new_state': LeapingFailure.State.WALK}

    return {'new_state': LeapingFailure.State.NO_CHANGE}

func _on_turn_around_timeout(failure: LeapingFailure) -> void:
    failure.set_direction(failure.direction * -1)
