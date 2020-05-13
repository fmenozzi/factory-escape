extends 'res://actors/enemies/state.gd'

var _player: Player = null

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    sentry_drone.get_animation_player().stop(false)

    # Display alerted reaction.
    sentry_drone.get_react_sprite().change_state(ReactSprite.State.ALERTED)

    # Turn to face player when alerted.
    sentry_drone.set_direction(Util.direction(sentry_drone, _player))

func exit(sentry_drone: RangedSentryDrone) -> void:
    # Hide reaction sprite.
    sentry_drone.get_react_sprite().change_state(ReactSprite.State.NONE)

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_aggro_range() or aggro_manager.can_see_player()):
        return {'new_state': RangedSentryDrone.State.UNALERTED}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
