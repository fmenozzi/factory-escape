extends 'res://actors/enemies/enemy_state.gd'

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    print('WORKER DRONE DIED')
    worker_drone.queue_free()

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    return {'new_state': WorkerDrone.State.NO_CHANGE}
