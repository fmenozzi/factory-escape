extends 'res://actors/enemies/state.gd'

var _player: Player = null

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    # Pause current animation.
    failure.get_animation_player().stop(false)

    # Display unalerted reaction.
    failure.get_react_sprite().change_state(ReactSprite.State.UNALERTED)

    _player = Util.get_player()

func exit(failure: LeapingFailure) -> void:
    # Hide reaction sprite.
    failure.get_react_sprite().change_state(ReactSprite.State.NONE)

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    # Transition back to alerted once back in aggro radius.
    if failure.is_in_range(_player, failure.AGGRO_RADIUS):
        return {'new_state': LeapingFailure.State.ALERTED}

    # Transition back to walk once out of "unaggro" radius.
    if not failure.is_in_range(_player, failure.UNAGGRO_RADIUS):
        return {'new_state': LeapingFailure.State.WALK}

    return {'new_state': LeapingFailure.State.NO_CHANGE}
