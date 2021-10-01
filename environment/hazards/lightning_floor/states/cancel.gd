extends 'res://actors/enemies/enemy_state.gd'

func enter(lightning_floor: LightningFloor, previous_state_dict: Dictionary) -> void:
    lightning_floor.get_hitbox_collision_shape().set_deferred('disabled', true)
    lightning_floor.get_indicator_lights().get_animation_player().play('reset_indicator_lights')
    for bolt in lightning_floor.get_bolts():
        bolt.dissipate()
        bolt.pause()
    lightning_floor.get_bolts_node().modulate.a = 0

func exit(lightning_floor: LightningFloor) -> void:
    pass

func update(lightning_floor: LightningFloor, delta: float) -> Dictionary:
    return {'new_state': LightningFloor.State.NO_CHANGE}
