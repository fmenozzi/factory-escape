extends 'res://actors/player/states/state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hazard_recover')

    # Reset the dash and double jump.
    player.reset_dash()
    player.reset_jump()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_pressed('player_jump') and player.can_jump():
        return {'new_state': Player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        # Play attack animation before returning to idle animation.
        player.start_attack()
        player.get_animation_player().queue('idle')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE_START,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once the animation is finished, enter the idle state.
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Allow exiting early if player tries to move.
    if Util.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.WALK}

    return {'new_state': Player.State.NO_CHANGE}