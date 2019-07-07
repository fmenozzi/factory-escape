extends 'res://scripts/state.gd'

func enter(player: Player, previous_state: int) -> void:
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

func handle_input(player: Player, event: InputEvent) -> int:
    if event.is_action_pressed('player_jump') and player.can_jump():
        return player.State.JUMP
    elif event.is_action_pressed('player_attack'):
        # Play attack animation before returning to idle animation.
        player.start_attack()
        player.get_animation_player().queue('idle')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return player.State.DASH

    return player.State.NO_CHANGE

func update(player: Player, delta: float) -> int:
    if Globals.get_input_direction() != 0:
        return player.State.WALK

    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # allows us to e.g. idle next to a wall (without pressing into it) and have
    # is_on_wall() correctly report that we're NOT on a wall, which is important
    # for not triggering wall slide when jumping up from idling next to a wall.
    player.move(Vector2(0, 10))

    return player.State.NO_CHANGE