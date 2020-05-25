extends 'res://actors/enemies/state.gd'

func enter(spider_drone: SpiderDrone, previous_state_dict: Dictionary) -> void:
    spider_drone.get_animation_player().play('walk')

func exit(spider_drone: SpiderDrone) -> void:
    pass

func update(spider_drone: SpiderDrone, delta: float) -> Dictionary:
    var physics_manager := spider_drone.get_physics_manager()

    var velocity := Vector2(
        spider_drone.direction * physics_manager.get_movement_speed(), 0)

    spider_drone.move(velocity, Util.NO_SNAP, spider_drone.get_floor_normal())

    return {'new_state': SpiderDrone.State.NO_CHANGE}
