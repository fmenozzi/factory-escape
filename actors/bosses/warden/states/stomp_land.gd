extends 'res://actors/enemies/enemy_state.gd'

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.get_animation_player().play('stomp_land')

    # Pitch the land sound down a bit since it's more impactful than the normal
    # version.
    var audio_player: AudioStreamPlayer = warden.get_sound_manager() \
        .get_player(WardenSoundManager.Sounds.LAND) \
        .get_player()
    audio_player.pitch_scale = 0.8
    audio_player.play()

    Screenshake.start(
        Screenshake.Duration.MEDIUM, Screenshake.Amplitude.MEDIUM,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.8, Rumble.Priority.HIGH)

func exit(warden: Warden) -> void:
    warden.get_stomp_hitbox().set_deferred('disabled', true)
    warden.get_stomp_dust_sprite().visible = false

    # Reset pitch scale.
    warden.get_sound_manager() \
        .get_player(WardenSoundManager.Sounds.LAND) \
        .get_player() \
        .pitch_scale = 1.0

func update(warden: Warden, delta: float) -> Dictionary:
    if not warden.get_animation_player().is_playing():
        return {'new_state': Warden.State.DISPATCH}

    return {'new_state': Warden.State.NO_CHANGE}
