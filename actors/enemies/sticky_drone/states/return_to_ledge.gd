extends 'res://actors/enemies/enemy_state.gd'

var _direction_to_ledge: int = Util.Direction.NONE

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    _direction_to_ledge = previous_state_dict['direction_to_ledge']
    assert(_direction_to_ledge != null)

    sticky_drone.set_direction(_direction_to_ledge)

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var physics_manager := sticky_drone.get_physics_manager()

    if not sticky_drone.is_off_ledge():
        return {'new_state': StickyDrone.State.WALK}

    sticky_drone.move(
        Vector2(_direction_to_ledge * physics_manager.get_movement_speed(), 10))

    return {'new_state': StickyDrone.State.NO_CHANGE}
