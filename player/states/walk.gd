extends 'res://scripts/state.gd'

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
    if event.is_action_pressed('player_jump') and player.can_jump():
        return {'new_state': player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        # Play attack animation before returning to walk animation.
        player.start_attack()
        player.get_animation_player().queue('walk')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return {'new_state': player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        if player.get_closest_grapple_point() != Vector2.ZERO:
            return {'new_state': player.State.GRAPPLE}

    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Change to idle state if we stop moving.
    var input_direction = Globals.get_input_direction()
    if input_direction == 0:
        return {'new_state': player.State.IDLE}

    # If we've walked off a platform, start falling.
    if player.is_in_air():
        return {'new_state': player.State.FALL}

    player.set_player_direction(input_direction)

    # Move left or right. Add in sufficient downward movement so that
    # is_on_floor() detects collisions with the floor and doesn't erroneously
    # report that we're in the air.
    player.move(Vector2(input_direction * player.MOVEMENT_SPEED, 10))

    return {'new_state': player.State.NO_CHANGE}
