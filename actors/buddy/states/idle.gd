extends 'res://actors/buddy/states/state.gd'

func enter(buddy: Buddy, previous_state_dict: Dictionary) -> void:
    buddy.get_animation_player().play('idle')
    buddy.get_readable_object().set_readable(true)

    buddy.get_readable_object().dialog = ['Hello there!']

func exit(buddy: Buddy) -> void:
    buddy.get_readable_object().set_readable(false)

func update(buddy: Buddy, delta: float) -> Dictionary:
    return {'new_state': Buddy.State.NO_CHANGE}
