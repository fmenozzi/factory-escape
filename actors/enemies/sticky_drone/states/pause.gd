extends 'res://actors/enemies/enemy_state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    pass

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    return {'new_state': StickyDrone.State.NO_CHANGE}
