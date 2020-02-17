extends 'res://actors/enemies/state.gd'

const FLY_SPEED := 2.0 * Util.TILE_SIZE

var _global_fly_to_point := Vector2.ZERO
var _direction_to_point := Vector2.ZERO

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    assert('fly_to_point' in previous_state_dict)
    _global_fly_to_point = previous_state_dict['fly_to_point']
    assert(_global_fly_to_point != null)

    _direction_to_point = worker_drone.global_position.direction_to(_global_fly_to_point)

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    # TODO: Maybe use some kind of easing/acceleration to make the movement
    #       smoother. Might even be possible to use a tween to move the drone.
    worker_drone.move(FLY_SPEED * _direction_to_point)

    # Once we reach the point, return to idle.
    if worker_drone.global_position.distance_to(_global_fly_to_point) < 2.0:
        return {'new_state': WorkerDrone.State.IDLE}

    # If we hit an obstacle, move away from it slightly and then return to idle.
    #
    # TODO: Might be a good idea to pick a new point in a slightly intelligent
    #       manner, as drones might e.g. get stuck under platforms near the
    #       bottom of the room for a few idle cycles, since most of the points
    #       in the room are above the platform and thus subject to collision.
    if worker_drone.is_hitting_obstacle():
        worker_drone.move(-FLY_SPEED * _direction_to_point)
        return {'new_state': WorkerDrone.State.IDLE}

    return {'new_state': WorkerDrone.State.NO_CHANGE}
