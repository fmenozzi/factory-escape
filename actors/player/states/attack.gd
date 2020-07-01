extends 'res://actors/player/states/player_state.gd'

var _attack_again := false

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.start_attack(player.get_attack_manager().get_next_attack_animation())

    _attack_again = false

func exit(player: Player) -> void:
    player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_pressed('player_attack'):
        if player.get_attack_manager().can_attack():
            _attack_again = true

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if not player.get_animation_player().is_playing():
        if _attack_again:
            return {'new_state': Player.State.ATTACK}
        elif player.is_in_air():
            return {'new_state': Player.State.FALL}
        else:
            return {'new_state': Player.State.IDLE}

    # Apply slight downward movement if grounded. This is useful for ensuring
    # that we snap to downward-moving platforms.
    if player.is_on_floor():
        player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
