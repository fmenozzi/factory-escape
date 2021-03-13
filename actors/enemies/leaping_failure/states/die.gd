extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play('die')

    failure.set_hit_and_hurt_boxes_disabled(true)
    failure.visible = false

func exit(failure: LeapingFailure) -> void:
    failure.set_hit_and_hurt_boxes_disabled(false)
    failure.visible = true

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    return {'new_state': LeapingFailure.State.NO_CHANGE}
