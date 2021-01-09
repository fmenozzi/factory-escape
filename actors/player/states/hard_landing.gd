extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hard_landing')
    player.get_sound_manager().play(PlayerSoundManager.Sounds.LAND_HARD)

    Rumble.start(Rumble.Type.WEAK, 0.25)

    # TODO: Maybe use the animation duration for the screenshake duration.
    Screenshake.start(Screenshake.Duration.MEDIUM, Screenshake.Amplitude.SMALL)

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # ensures that we move along with moving platforms if we hard land on top of
    # one.
    player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
