extends 'res://actors/enemies/state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('idle')

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    return {'new_state': StickyDrone.State.NO_CHANGE}
