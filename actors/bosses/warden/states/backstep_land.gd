extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('land')
    warden.get_sound_manager().play(WardenSoundManager.Sounds.LAND)
    warden.emit_dust_puff_land()

    Screenshake.start(Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)
    Rumble.start(Rumble.Type.WEAK, 0.2)

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {'new_state': Warden.State.DISPATCH}

    return {'new_state': Warden.State.NO_CHANGE}
