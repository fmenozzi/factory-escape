extends 'res://actors/enemies/state.gd'

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('walk')

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var physics_manager := sticky_drone.get_physics_manager()

    var velocity := Vector2(
        sticky_drone.direction * physics_manager.get_movement_speed(), 0)

    sticky_drone.move(velocity, Util.NO_SNAP, sticky_drone.get_floor_normal())

    return {'new_state': StickyDrone.State.NO_CHANGE}
