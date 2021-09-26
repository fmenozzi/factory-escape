extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('jump')

    warden.set_direction(Util.direction(warden, Util.get_player()))

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
