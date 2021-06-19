extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Set initial jump velocity to max jump velocity (releasing the jump button
    # will cause the velocity to "cut", allowing for variable-height jumps).
    player.velocity.y = player.get_physics_manager().get_max_jump_velocity()

    # If the jump button isn't being pressed upon entering the jump state, this
    # means we must be buffer jumping, as the player may have released the jump
    # button between triggering the buffering and entering the actual jump
    # state. In this case, we jump cut early so that we perform a min-jump
    # instead of a max jump.
    #
    # TODO: Consider whether something in-between would be optimal, as a min
    #       jump is quite low. Maybe lerp between min-jump and max-jump with a
    #       small weight?
    if not Input.is_action_pressed('player_jump'):
        _jump_cut(player)

    player.get_animation_player().play('jump')
    player.get_sound_manager().play(PlayerSoundManager.Sounds.JUMP)

    # Emit a jump puff.
    player.emit_dust_puff()

    # Consume the jump until it is reset by e.g. hitting the ground.
    player.get_jump_manager().consume_jump()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()
    var grapple_manager := player.get_grapple_manager()
    var wall_jump_manager := player.get_wall_jump_manager()

    if event.is_action_released('player_jump'):
        # "Jump cut" if the jump button is released.
        _jump_cut(player)
    elif event.is_action_pressed('player_jump'):
        if (wall_jump_manager.is_near_wall_front() or wall_jump_manager.is_near_wall_back()) and wall_jump_manager.can_wall_jump():
            # Wall jump.
            return {'new_state': Player.State.WALL_JUMP}
        elif jump_manager.can_jump():
            # Double jump.
            return {'new_state': Player.State.DOUBLE_JUMP}
    elif event.is_action_pressed('player_attack'):
        if Input.is_action_pressed('player_move_up'):
            return {
                'new_state': Player.State.ATTACK_UP,
                'velocity': player.velocity,
            }
        elif player.get_attack_manager().can_attack():
            return {
                'new_state': Player.State.ATTACK,
                'velocity': player.velocity,
            }
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
        return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := grapple_manager.get_next_grapple_point()
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

func _jump_cut(player: Player) -> void:
    player.velocity.y = max(
        player.velocity.y, player.get_physics_manager().get_min_jump_velocity())
