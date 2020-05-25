extends 'res://actors/enemies/state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('uncrouch')

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    if not sticky_drone.get_animation_player().is_playing():
        return {'new_state': StickyDrone.State.IDLE}

    return {'new_state': StickyDrone.State.NO_CHANGE}
