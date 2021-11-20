extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('explode')
    warden.get_sound_manager().play(WardenSoundManager.Sounds.DEATH_EXPLODE)

    Screenshake.start(
        Screenshake.Duration.MEDIUM, Screenshake.Amplitude.MEDIUM,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 1.0, Rumble.Priority.HIGH)

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {'new_state': Warden.State.IDLE}

    return {'new_state': Warden.State.NO_CHANGE}
