extends "res://scripts/state.gd"

func enter(player: Player, previous_state: int) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Stop attack animation, in case we were attacking in previous state.
    player.stop_attack()

    # Play wall slide animation.
    player.get_animation_player().play('wall_slide')

    # Start wall slide trail effect.
    player.get_wall_slide_trail().emitting = true

    # Reset the dash and double jump.
    player.reset_dash()
    player.reset_jump()

func exit(player: Player) -> void:
    # Stop wall slide trail effect.
    player.get_wall_slide_trail().emitting = false

func handle_input(player: Player, event: InputEvent) -> int:
    if event.is_action_pressed('player_jump'):
        return player.State.WALL_JUMP
    elif event.is_action_pressed('player_dash'):
        # Flip the player to face away from the wall before dashing.
        player.set_player_direction(-1 * player.get_player_direction())
        return player.State.DASH

    return player.State.NO_CHANGE

func update(player: Player, delta: float) -> int:
    # Once we hit the ground, return to idle state.
    if player.is_on_ground():
        return player.State.IDLE

    # If we're not on the ground or the wall, the wall must have disappeared out
    # from under us, so we transition to falling. Because we've been pushing
    # into the wall in order to get is_on_wall() to return true, correct by the
    # same distance away from the wall so that when we land we can jump up onto
    # the wall without hitting our heads.
    if not player.is_on_wall():
        player.move(Vector2(-10 * player.get_player_direction(), 0))
        return player.State.FALL

    # Slide down with constant speed after a slight acceleration. Also move the 
    # character slightly into the wall to maintain collision with the wall so
    # that is_on_wall() continues to return true.
    player.velocity.x = 10 * player.get_player_direction()
    player.velocity.y = min(player.velocity.y + 5, player.MOVEMENT_SPEED)
    player.move(player.velocity)

    return player.State.NO_CHANGE