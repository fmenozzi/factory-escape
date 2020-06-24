extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.start_attack(player.get_attack_manager().get_next_attack_animation())

func exit(player: Player) -> void:
    player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        if player.is_in_air():
            return {'new_state': Player.State.FALL}
        else:
            return {'new_state': Player.State.IDLE}

    # Turn left or right.
    var input_direction = player.get_input_direction()
    if input_direction != Util.Direction.NONE:
        player.set_direction(input_direction)

    # Apply slight downward movement. This is useful both for if the player is
    # attacking in midair (so that they fall slowly and have a chance to connect
    # with midair enemies) and if the player is already grounded (so that they
    # snap to the ground and the ground doesn't disappear out from under them,
    # such as from a downward-moving platform).
    player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
