extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    pass

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    return {'new_state': Warden.State.NO_CHANGE}
