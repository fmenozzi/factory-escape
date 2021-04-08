extends 'res://actors/enemies/enemy_state.gd'

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    pass

func exit(turret: Turret) -> void:
    pass

func update(turret: Turret, delta: float) -> Dictionary:
    return {'new_state': Turret.State.NO_CHANGE}
