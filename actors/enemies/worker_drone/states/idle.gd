extends 'res://actors/enemies/state.gd'

func enter(worker_drone, previous_state_dict: Dictionary) -> void:
    pass

func exit(worker_drone) -> void:
    pass

func update(worker_drone, delta: float) -> Dictionary:
    return {'new_state': Slime.State.NO_CHANGE}
