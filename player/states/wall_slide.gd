extends "res://scripts/state.gd"

# Multiplier to reduce gravity while wall sliding.
const GRAVITY_MULTIPLIER: float = 0.5

func enter(player: Player, previous_state: int) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Stop attack animation, in case we were attacking in previous state.
    player.stop_attack()

    # Play wall slide animation.
    player.get_animation_player().play('wall_slide')

    # Start wall slide trail effect.
    player.get_sfx().start_wall_slide_trail()

func exit(player: Player) -> void:
    player.get_sfx().stop_wall_slide_trail()

func handle_input(player: Player, event: InputEvent) -> int:
    # TODO: Handle jumping off the wall.

    return player.State.NO_CHANGE

func update(player: Player, delta: float) -> int:
    # Once we hit the ground, return to idle state.
    if player.is_on_ground():
        return player.State.IDLE

    # If we're not on the ground or the wall, the wall must have disappeared out
    # from under us, so we transition to falling.
    if not player.is_on_wall():
        return player.State.FALL

    # Slide down with reduced gravity. Also move the character slightly into the
    # wall to maintain collision with the wall so that is_on_wall() continues to
    # return true.
    player.velocity.x = 10 * player.get_player_direction()
    player.velocity.y += GRAVITY_MULTIPLIER * player.GRAVITY * delta
    player.move(player.velocity)

    return player.State.NO_CHANGE