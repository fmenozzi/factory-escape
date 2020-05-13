extends 'res://actors/enemies/state.gd'

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('idle')

func exit(sentry_drone: RangedSentryDrone) -> void:
    pass

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': RangedSentryDrone.State.ALERTED}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
