extends 'res://actors/enemies/enemy_state.gd'

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_projectile_spawner().emit_signal('projectile_spawner_destroyed')

    sentry_drone.get_animation_player().play('die')

    sentry_drone.set_hit_and_hurt_boxes_disabled(true)
    sentry_drone.visible = false

func exit(sentry_drone: RangedSentryDrone) -> void:
    sentry_drone.set_hit_and_hurt_boxes_disabled(false)
    sentry_drone.visible = true

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
