extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    print('LEAPING FAILURE DIED')
    failure.queue_free()

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    return {'new_state': LeapingFailure.State.NO_CHANGE}
