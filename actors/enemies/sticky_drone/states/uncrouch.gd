extends 'res://actors/enemies/enemy_state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('uncrouch')

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()

    if not sticky_drone.get_animation_player().is_playing():
        # Once aggroed, sticky drone will only unaggro when out of range, and
        # NOT when player is no longer in line of sight (i.e. the drone will
        # "track" the player through cover).
        if not aggro_manager.in_aggro_range():
            return {'new_state': StickyDrone.State.UNALERTED}

        return {'new_state': StickyDrone.State.IDLE}

    return {'new_state': StickyDrone.State.NO_CHANGE}
