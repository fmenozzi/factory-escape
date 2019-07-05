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

    # TODO: Emit wall slide puff

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> int:
    # TODO: Handle jumping off the wall.

    return player.State.NO_CHANGE

func update(player: Player, delta: float) -> int:
    # Once we hit the ground, return to idle state.
    if player.is_on_ground():
        return player.State.IDLE

    # Slide down with reduced gravity.
    player.velocity.y += GRAVITY_MULTIPLIER * player.GRAVITY * delta
    player.move(player.velocity)

    return player.State.NO_CHANGE