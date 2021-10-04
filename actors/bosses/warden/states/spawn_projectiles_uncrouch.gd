extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('lightning_floor_uncrouch')

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {'new_state': Warden.State.DISPATCH}

    return {'new_state': Warden.State.NO_CHANGE}
