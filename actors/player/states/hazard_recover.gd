extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    player.get_animation_player().play('hazard_recover')

    # Reset the dash and double jump.
    player.get_dash_manager().reset_dash()
    player.get_jump_manager().reset_jump()

func exit(player: Player) -> void:
    player.get_hazard_hit_invincibility_flash_manager().stop_flashing()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()

    if event.is_action_pressed('player_jump') and jump_manager.can_jump():
        return {'new_state': Player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        if Input.is_action_pressed('player_move_up'):
            return {'new_state': Player.State.ATTACK_UP}
        elif player.get_attack_manager().can_attack():
            return {'new_state': Player.State.ATTACK}
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
        return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_grapple_manager().get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE,
                'grapple_point': next_grapple_point,
            }
    elif event.is_action_pressed('player_heal'):
        if player.get_health_pack_manager().can_heal():
            return {'new_state': Player.State.HEAL}
        else:
            player.emit_signal('player_heal_attempted_no_health_packs')

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # is important for platform crush detection, where we use is_on_ceiling() as
    # part of the check to see if we're being crushed by platforms. Without the
    # additional calls to move_and_slide(), is_on_ceiling() would continue to be
    # true even after we've teleported to the hazard checkpoint and entered the
    # HAZARD_RECOVER state.
    #
    # It's important that we call this BEFORE the possible state transitions
    # below, as we need to update collisions first. Otherwise, holding the left
    # stick while recovering from a hazard will immediately transition to WALK
    # before physics have had a chance to update, which would cause continuous
    # crushing as described above.
    player.move(Vector2(0, player.get_slight_downward_move()))

    # Once the animation is finished, enter the idle state.
    if not player.get_animation_player().is_playing():
        return {'new_state': Player.State.IDLE}

    # Allow exiting early if player tries to move.
    if player.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.WALK}

    return {'new_state': Player.State.NO_CHANGE}
