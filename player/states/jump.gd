extends 'res://scripts/state.gd'

const LandingPuff := preload('res://sfx/LandingPuff.tscn')

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Set initial jump velocity to max jump velocity (releasing the jump button
    # will cause the velocity to "cut", allowing for variable-height jumps).
    player.velocity.y = player.MAX_JUMP_VELOCITY

    # Stop attack animation, in case we were attacking in previous state.
    player.stop_attack()

    # Play jump animation.
    player.get_animation_player().play('jump')

    # Emit a jump puff.
    Globals.spawn_particles(LandingPuff.instance(), player)

    # Consume the jump until it is reset by e.g. hitting the ground.
    player.consume_jump()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_released('player_jump'):
        # "Jump cut" if the jump button is released.
        player.velocity.y = max(player.velocity.y, player.MIN_JUMP_VELOCITY)
    elif event.is_action_pressed('player_jump'):
        if player.is_near_wall_front() or player.is_near_wall_back():
            # Wall jump.
            return {'new_state': player.State.WALL_JUMP}
        elif player.can_jump():
            # Double jump.
            return {'new_state': player.State.DOUBLE_JUMP}
    elif event.is_action_pressed('player_attack'):
        player.start_attack()
        player.get_animation_player().queue('jump')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return {'new_state': player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': player.State.GRAPPLE_START,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Switch to 'fall' state once we reach apex of jump.
    if player.velocity.y >= 0:
        return {'new_state': player.State.FALL}

    # Move left or right.
    var input_direction = Globals.get_input_direction()
    if input_direction != 0:
        player.set_player_direction(input_direction)
    player.velocity.x = input_direction * player.MOVEMENT_SPEED

    # Move due to gravity.
    player.velocity.y += player.GRAVITY * delta

    player.move(player.velocity)

    return {'new_state': player.State.NO_CHANGE}
