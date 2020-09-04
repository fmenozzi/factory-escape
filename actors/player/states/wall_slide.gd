extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Stop attack animation, in case we were attacking in previous state.
    player.stop_attack()

    # Play wall slide animation.
    player.get_animation_player().play('wall_slide')

    # Start wall slide trail effect.
    player.get_wall_slide_trail().emitting = true

    # Reset the dash and double jump.
    player.get_dash_manager().reset_dash()
    player.get_jump_manager().reset_jump()

func exit(player: Player) -> void:
    # Stop wall slide trail effect.
    player.get_wall_slide_trail().emitting = false

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var dash_manager := player.get_dash_manager()
    var grapple_manager := player.get_grapple_manager()
    var wall_jump_manager := player.get_wall_jump_manager()

    if event.is_action_pressed('player_jump') and wall_jump_manager.can_wall_jump():
        return {'new_state': Player.State.WALL_JUMP}
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
        # Flip the player to face away from the wall before dashing.
        player.set_direction(-1 * player.get_direction())
        player.emit_dust_puff()
        return {'new_state': Player.State.DASH}
    # Let the player exit wall slide by moving away from the wall.
    elif event.is_action_pressed('player_move_left'):
        if player.get_direction() == Util.Direction.RIGHT:
            player.set_direction(Util.Direction.LEFT)
            player.move(Vector2(-10, 0))
            return {'new_state': Player.State.FALL}
    elif event.is_action_pressed('player_move_right'):
        if player.get_direction() == Util.Direction.LEFT:
            player.set_direction(Util.Direction.RIGHT)
            player.move(Vector2(10, 0))
            return {'new_state': Player.State.FALL}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := grapple_manager.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    # Once we hit the ground, return to idle state.
    if player.is_on_ground():
        return {'new_state': Player.State.IDLE}

    # If we're not on the ground or the wall, the wall must have disappeared out
    # from under us, so we transition to falling. Because we've been pushing
    # into the wall in order to get is_on_wall() to return true, correct by the
    # same distance away from the wall so that when we land we can jump up onto
    # the wall without hitting our heads.
    if not player.is_on_wall():
        player.move(Vector2(-10 * player.get_direction(), 0))
        return {'new_state': Player.State.FALL}

    # Slide down with constant speed after a slight acceleration. Also move the
    # character slightly into the wall to maintain collision with the wall so
    # that is_on_wall() continues to return true. Snap to the wall to make wall
    # sliding on moving platforms look slightly less janky when not pressing
    # into the direction of the moving platform.
    var snap := Util.NO_SNAP
    match player.get_direction():
        Util.Direction.LEFT:
            snap = Vector2.LEFT
        Util.Direction.RIGHT:
            snap = Vector2.RIGHT
    player.velocity.x = 10 * player.get_direction()
    player.velocity.y = min(
        player.velocity.y + 5, physics_manager.get_movement_speed())
    player.move(player.velocity, snap)

    return {'new_state': Player.State.NO_CHANGE}
