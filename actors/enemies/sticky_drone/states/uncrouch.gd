extends 'res://actors/enemies/enemy_state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('uncrouch')

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()

    if not sticky_drone.get_animation_player().is_playing():
        if not aggro_manager.in_unaggro_range() or not aggro_manager.can_see_player():
            return {'new_state': StickyDrone.State.UNALERTED}

        return {'new_state': StickyDrone.State.IDLE}

    return {'new_state': StickyDrone.State.NO_CHANGE}
