extends 'res://actors/enemies/enemy_state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('die')

    sticky_drone.set_hit_and_hurt_boxes_disabled(true)
    sticky_drone.visible = false

func exit(sticky_drone: StickyDrone) -> void:
    sticky_drone.set_hit_and_hurt_boxes_disabled(false)
    sticky_drone.visible = true

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    return {'new_state': StickyDrone.State.NO_CHANGE}
