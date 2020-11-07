extends 'res://actors/enemies/enemy_state.gd'

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    worker_drone.set_hit_and_hurt_boxes_disabled(true)
    worker_drone.visible = false

func exit(worker_drone: WorkerDrone) -> void:
    worker_drone.set_hit_and_hurt_boxes_disabled(false)
    worker_drone.visible = true

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    return {'new_state': WorkerDrone.State.NO_CHANGE}
