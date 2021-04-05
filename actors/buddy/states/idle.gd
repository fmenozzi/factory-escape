extends 'res://actors/buddy/states/state.gd'

var _player: Player = null

func enter(buddy: Buddy, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    buddy.get_animation_player().play('idle')
    buddy.get_readable_object().set_readable(true)

    buddy.get_readable_object().dialog = ['Hello there!']

func exit(buddy: Buddy) -> void:
    buddy.get_readable_object().set_readable(false)

func update(buddy: Buddy, delta: float) -> Dictionary:
    buddy.set_direction(Util.direction(buddy, _player))

    return {'new_state': Buddy.State.NO_CHANGE}
