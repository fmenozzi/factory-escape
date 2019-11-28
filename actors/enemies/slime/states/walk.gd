extends 'res://actors/enemies/state.gd'

func enter(slime: Slime, previous_state_dict: Dictionary) -> void:
    slime.get_node('AnimationPlayer').play('walk')

func exit(slime: Slime) -> void:
    pass

func update(slime: Slime, delta: float) -> Dictionary:
    slime.move(Vector2(slime.direction * slime.SPEED, 10))

    if slime.is_on_wall() or slime.is_touching_hazard():
        slime.set_direction(-1 * slime.direction)
    elif not slime.is_on_floor():
        return {'new_state': Slime.State.FALL}

    return {'new_state': Slime.State.NO_CHANGE}