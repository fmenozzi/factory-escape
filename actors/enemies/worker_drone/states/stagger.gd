extends 'res://actors/enemies/enemy_state.gd'

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    var direction_from_hit: Vector2 = previous_state_dict['direction_from_hit']
    assert(direction_from_hit != null)

    worker_drone.get_pushback_manager().start_pushback(direction_from_hit)

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    var pushback_manager := worker_drone.get_pushback_manager()

    if not pushback_manager.is_being_pushed_back():
        return {'new_state': WorkerDrone.State.WANDER}

    worker_drone.move(pushback_manager.get_pushback_velocity())

    return {'new_state': WorkerDrone.State.NO_CHANGE}
