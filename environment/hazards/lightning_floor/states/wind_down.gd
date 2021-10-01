extends 'res://actors/enemies/enemy_state.gd'

onready var _tween: Tween = $AlphaTween

func enter(lightning_floor: LightningFloor, previous_state_dict: Dictionary) -> void:
    lightning_floor.get_indicator_lights().get_animation_player().play('wind_down')
    for bolt in lightning_floor.get_bolts():
        bolt.dissipate()
        bolt.pause()

    _tween.remove_all()
    _tween.interpolate_property(
        lightning_floor.get_bolts_node(), 'modulate:a', 1.0, 0.0, 0.15)
    _tween.start()

func exit(lightning_floor: LightningFloor) -> void:
    pass

func update(lightning_floor: LightningFloor, delta: float) -> Dictionary:
    if not lightning_floor.get_indicator_lights().get_animation_player().is_playing():
        return {'new_state': LightningFloor.State.CANCEL}

    return {'new_state': LightningFloor.State.NO_CHANGE}
