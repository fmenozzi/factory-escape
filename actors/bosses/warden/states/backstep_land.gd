extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('land')

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {
            'new_state': Warden.State.LEAP_TO_CENTER,
            'center_global_position': warden.get_room_center_global_position(),
        }

    return {'new_state': Warden.State.NO_CHANGE}
