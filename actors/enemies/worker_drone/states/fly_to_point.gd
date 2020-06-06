extends 'res://actors/enemies/enemy_state.gd'

const ACCEL_DISTANCE := 1.0 * Util.TILE_SIZE
const DECEL_DISTANCE := 1.0 * Util.TILE_SIZE

export(float, EASE) var accel_easing := 0.05

var _global_fly_to_point := Vector2.ZERO
var _direction_to_point := Vector2.ZERO
var _distance_to_point := 0.0

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    assert('fly_to_point' in previous_state_dict)
    _global_fly_to_point = previous_state_dict['fly_to_point']
    assert(_global_fly_to_point != null)

    var drone_global_pos := worker_drone.global_position
    _direction_to_point = drone_global_pos.direction_to(_global_fly_to_point)
    _distance_to_point = drone_global_pos.distance_to(_global_fly_to_point)

    if _direction_to_point.x > 0:
        worker_drone.set_direction(Util.Direction.RIGHT)
    else:
        worker_drone.set_direction(Util.Direction.LEFT)

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    var physics_manager := worker_drone.get_physics_manager()
    var speed := physics_manager.get_movement_speed()
    var speed_multiplier := _get_speed_multiplier(worker_drone)
    worker_drone.move(speed_multiplier * speed * _direction_to_point)

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
        worker_drone.move(-speed * _direction_to_point)
        return {'new_state': WorkerDrone.State.IDLE}

    return {'new_state': WorkerDrone.State.NO_CHANGE}

func _get_speed_multiplier(worker_drone: WorkerDrone) -> float:
    var current_distance_to_point := worker_drone.global_position.distance_to(
        _global_fly_to_point)
    var distance_travelled := _distance_to_point - current_distance_to_point

    var speed_multiplier := 1.0

    if distance_travelled <= ACCEL_DISTANCE:
        # Acceleration for the first ACCEL_DISTANCE pixels travelled.
        speed_multiplier = ease(
            distance_travelled / ACCEL_DISTANCE, accel_easing)
    elif current_distance_to_point <= DECEL_DISTANCE:
        # Deceleration for the last DECEL_DISTANCE pixels travelled.
        speed_multiplier = ease(
            current_distance_to_point / DECEL_DISTANCE, 1.0 - accel_easing)

    # Ensure our speed is non-zero, since the ease-in curve starts at zero and
    # would result in the drone never moving.
    return clamp(speed_multiplier, 0.2, 1.0)
