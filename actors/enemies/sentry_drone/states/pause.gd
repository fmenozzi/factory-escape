extends 'res://actors/enemies/enemy_state.gd'

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    pass

func exit(sentry_drone: SentryDrone) -> void:
    pass

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    return {'new_state': SentryDrone.State.NO_CHANGE}
