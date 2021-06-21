extends 'res://actors/enemies/enemy_state.gd'

const ALERTED_DURATION: float = 0.25

var _player: Player = null

onready var _timer: Timer = $AlertedDurationTimer

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = ALERTED_DURATION

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    failure.get_animation_player().stop(false)

    failure.get_sound_manager().play(LeapingFailureSoundManager.Sounds.ALERTED)

    # Display alerted reaction.
    failure.get_react_sprite().change_state(ReactSprite.State.ALERTED)

    # Turn to face player when alerted.
    failure.set_direction(Util.direction(failure, _player))

    # Start duration timer.
    _timer.start()

func exit(failure: LeapingFailure) -> void:
    # Hide reaction sprite.
    failure.get_react_sprite().change_state(ReactSprite.State.NONE)

    # Stop duration timer.
    _timer.stop()

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    var aggro_manager := failure.get_aggro_manager()

    if _timer.is_stopped():
        return {'new_state': LeapingFailure.State.LEAP}

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_aggro_range() or aggro_manager.can_see_player()):
        return {'new_state': LeapingFailure.State.UNALERTED}

    return {'new_state': LeapingFailure.State.NO_CHANGE}
