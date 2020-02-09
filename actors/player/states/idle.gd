extends 'res://actors/player/states/state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Let attack animation play out before switching to idle animation.
    if player.is_attacking():
        player.get_animation_player().clear_queue()
        player.get_animation_player().queue('idle')
    else:
        player.get_animation_player().play('idle')

    # Reset the dash and double jump.
    player.reset_dash()
    player.reset_jump()

func exit(player: Player) -> void:
    # In case we exit the idle state before the previously-playing attack
    # animation finishes, stop the attack, which has the effect of both flushing
    # the animation queue and hiding the attack sprite.
    if player.is_attacking():
        player.stop_attack()

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
