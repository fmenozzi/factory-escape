extends 'res://actors/enemies/enemy_state.gd'

func enter(crusher: Crusher, previous_state_dict: Dictionary) -> void:
    assert('animation' in previous_state_dict)
    crusher.get_animation_player().play(previous_state_dict['animation'])

func exit(crusher: Crusher) -> void:
    pass

func update(crusher: Crusher, delta: float) -> Dictionary:
    return {'new_state': Crusher.State.NO_CHANGE}
