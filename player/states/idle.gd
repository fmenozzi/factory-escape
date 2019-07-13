extends 'res://scripts/state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Stop attack animation, in case we were attacking in previous state.
    player.stop_attack()

    # Play idle animation
    player.get_animation_player().play('idle')

    # Reset the dash and double jump.
    player.reset_dash()
    player.reset_jump()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_pressed('player_jump') and player.can_jump():
        return {'new_state': player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        # Play attack animation before returning to idle animation.
        player.start_attack()
        player.get_animation_player().queue('idle')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return {'new_state': player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        if player.get_closest_grapple_point() != Vector2.ZERO:
            return {'new_state': player.State.GRAPPLE_START}

    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if Globals.get_input_direction() != 0:
        return {'new_state': player.State.WALK}

    # It's possible to inch off a ledge and no longer be on the ground directly
    # from the idle state (i.e. without having to first transition to the walk
    # state), so include direct transition to fall state. Otherwise, the slight
    # downward movement below will cause us to fall very slowly in the air.
    if player.is_in_air():
        return {'new_state': player.State.FALL}

    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # allows us to e.g. idle next to a wall (without pressing into it) and have
    # is_on_wall() correctly report that we're NOT on a wall, which is important
    # for not triggering wall slide when jumping up from idling next to a wall.
    player.move(Vector2(0, 10))

    return {'new_state': player.State.NO_CHANGE}
