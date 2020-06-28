extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    if player.get_health().get_current_health() == 1:
        player.get_animation_player().play('idle_low_health')
    else:
        player.get_animation_player().play('idle')

    # Reset the dash and double jump.
    player.get_dash_manager().reset_dash()
    player.get_jump_manager().reset_jump()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()

    if event.is_action_pressed('player_jump') and jump_manager.can_jump():
        return {'new_state': Player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        if Input.is_action_pressed("player_move_up"):
            return {'new_state': Player.State.ATTACK_UP}
        elif player.get_attack_manager().can_attack():
            return {'new_state': Player.State.ATTACK}
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
        return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if player.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.WALK}

    # It's possible to inch off a ledge and no longer be on the ground directly
    # from the idle state (i.e. without having to first transition to the walk
    # state), so include direct transition to fall state. Otherwise, the slight
    # downward movement below will cause us to fall very slowly in the air.
    if player.is_in_air():
        return {'new_state': Player.State.FALL}

    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # allows us to e.g. idle next to a wall (without pressing into it) and have
    # is_on_wall() correctly report that we're NOT on a wall, which is important
    # for not triggering wall slide when jumping up from idling next to a wall.
    player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
