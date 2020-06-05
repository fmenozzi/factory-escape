extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hazard_recover')

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
        # Play attack animation before returning to idle animation.
        player.start_attack()
        player.get_animation_player().queue('idle')
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
    # Once the animation is finished, enter the idle state.
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Allow exiting early if player tries to move.
    if player.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.WALK}

    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # is important for platform crush detection, where we use is_on_ceiling() as
    # part of the check to see if we're being crushed by platforms. Without the
    # additional calls to move_and_slide(), is_on_ceiling() would continue to be
    # true even after we've teleported to the hazard checkpoint and entered the
    # HAZARD_RECOVER state.
    player.move(Vector2(0, 10))

    return {'new_state': Player.State.NO_CHANGE}
