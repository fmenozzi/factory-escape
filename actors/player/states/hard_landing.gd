extends 'res://actors/player/states/state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hard_landing')

    Rumble.start(Rumble.Type.WEAK, 0.25)

    # TODO: Maybe use the animation duration for the screenshake duration.
    Screenshake.start(
        Screenshake.DURATION_MEDIUM,
        Screenshake.FREQ,
        Screenshake.AMPLITUDE_SMALL)

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}
