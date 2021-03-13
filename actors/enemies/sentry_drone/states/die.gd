extends 'res://actors/enemies/enemy_state.gd'

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('die')

    sentry_drone.set_hit_and_hurt_boxes_disabled(true)
    sentry_drone.visible = false

func exit(sentry_drone: SentryDrone) -> void:
    sentry_drone.set_hit_and_hurt_boxes_disabled(false)
    sentry_drone.visible = true

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    return {'new_state': SentryDrone.State.NO_CHANGE}
