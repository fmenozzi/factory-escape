extends 'res://actors/enemies/enemy_state.gd'

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    pass

func exit(sentry_drone: RangedSentryDrone) -> void:
    pass

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
