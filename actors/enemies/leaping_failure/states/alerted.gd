extends 'res://actors/enemies/state.gd'

var _player: Player = null

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    failure.get_animation_player().stop(false)

    # Display alerted reaction.
    failure.get_react_sprite().change_state(ReactSprite.State.ALERTED)

    # Turn to face player when alerted.
    failure.set_direction(Util.direction(failure, _player))

func exit(failure: LeapingFailure) -> void:
    # Hide reaction sprite.
    failure.get_react_sprite().change_state(ReactSprite.State.NONE)

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    # Transition to unalerted state once outside of aggro radius.
    if not failure.is_in_range(_player, failure.AGGRO_RADIUS):
        return {'new_state': LeapingFailure.State.UNALERTED}

    return {'new_state': LeapingFailure.State.NO_CHANGE}
