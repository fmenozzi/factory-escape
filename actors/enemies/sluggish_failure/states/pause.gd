extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    pass

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    return {'new_state': SluggishFailure.State.NO_CHANGE}
