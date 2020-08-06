extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    print('SLUGGISH FAILURE DIED')

    failure.get_animation_player().stop()

    failure.set_hit_and_hurt_boxes_disabled(true)
    failure.visible = false

func exit(failure: SluggishFailure) -> void:
    failure.set_hit_and_hurt_boxes_disabled(false)
    failure.visible = true

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    return {'new_state': SluggishFailure.State.NO_CHANGE}
