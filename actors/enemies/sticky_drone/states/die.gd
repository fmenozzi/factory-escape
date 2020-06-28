extends 'res://actors/enemies/enemy_state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    print('STICKY DRONE DIED')
    sticky_drone.queue_free()

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    return {'new_state': StickyDrone.State.NO_CHANGE}
