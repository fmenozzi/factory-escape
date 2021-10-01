extends 'res://actors/enemies/enemy_state.gd'

func enter(lightning_floor: LightningFloor, previous_state_dict: Dictionary) -> void:
    lightning_floor.get_indicator_lights().get_animation_player().play('telegraph')

func exit(lightning_floor: LightningFloor) -> void:
    pass

func update(lightning_floor: LightningFloor, delta: float) -> Dictionary:
    if not lightning_floor.get_indicator_lights().get_animation_player().is_playing():
        return {'new_state': LightningFloor.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': LightningFloor.State.NO_CHANGE}
