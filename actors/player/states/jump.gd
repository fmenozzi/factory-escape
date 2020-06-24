extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Set initial jump velocity to max jump velocity (releasing the jump button
    # will cause the velocity to "cut", allowing for variable-height jumps).
    player.velocity.y = player.get_physics_manager().get_max_jump_velocity()

    player.get_animation_player().play('jump')

    # Emit a jump puff.
    player.emit_dust_puff()

    # Consume the jump until it is reset by e.g. hitting the ground.
    player.get_jump_manager().consume_jump()

func exit(player: Player) -> void:
    # In case we exit the jump state before the previously-playing attack
    # animation finishes, stop the attack, which has the effect of both flushing
    # the animation queue and hiding the attack sprite.
    if player.is_attacking():
        player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var physics_manager := player.get_physics_manager()
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()

    if event.is_action_released('player_jump'):
        # "Jump cut" if the jump button is released.
        player.velocity.y = max(
            player.velocity.y, physics_manager.get_min_jump_velocity())
    elif event.is_action_pressed('player_jump'):
        if player.is_near_wall_front() or player.is_near_wall_back():
            # Wall jump.
            return {'new_state': Player.State.WALL_JUMP}
        elif jump_manager.can_jump():
            # Double jump.
            return {'new_state': Player.State.DOUBLE_JUMP}
    elif event.is_action_pressed('player_attack'):
        if Input.is_action_pressed('player_move_up'):
            return {'new_state': Player.State.ATTACK_UP}
        else:
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
    var physics_manager := player.get_physics_manager()

    # Switch to 'fall' state once we reach apex of jump.
    if player.velocity.y >= 0:
        return {'new_state': Player.State.FALL}

    # Move left or right.
    var input_direction = player.get_input_direction()
    if input_direction != Util.Direction.NONE:
        player.set_direction(input_direction)
    player.velocity.x = input_direction * physics_manager.get_movement_speed()

    # Move due to gravity.
    player.velocity.y += physics_manager.get_gravity() * delta

    # Don't snap while jumping.
    player.move(player.velocity, Util.NO_SNAP)

    return {'new_state': Player.State.NO_CHANGE}
