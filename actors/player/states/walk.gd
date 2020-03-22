extends 'res://actors/player/states/state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Stop attack animation, in case we were attacking in previous state.
    player.stop_attack()

    # Play walk animation.
    player.get_animation_player().play('walk')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()

    if event.is_action_pressed('player_jump') and jump_manager.can_jump():
        return {'new_state': Player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        # Play attack animation before returning to walk animation.
        player.start_attack()
        player.get_animation_player().queue('walk')
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
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
    # Change to idle state if we stop moving.
    var input_direction = player.get_input_direction()
    if input_direction == Util.Direction.NONE:
        return {'new_state': Player.State.IDLE}

    # If we've walked off a platform, start falling.
    if player.is_in_air():
        return {'new_state': Player.State.FALL}

    player.set_direction(input_direction)

    # Move left or right. Add in sufficient downward movement so that
    # is_on_floor() detects collisions with the floor and doesn't erroneously
    # report that we're in the air.
    var speed := player.get_physics_manager().get_movement_speed()
    player.move(Vector2(input_direction * speed, 10))

    return {'new_state': Player.State.NO_CHANGE}
