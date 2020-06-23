extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.start_attack('attack_up')

func exit(player: Player) -> void:
    player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Apply slight downward movement. This is important mostly for ensuring that
    # we're snapped to the ground, so that the ground doesn't disappear out from
    # under us during the attack, such as if we're on a downward-moving platform.
    player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
