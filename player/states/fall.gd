extends 'res://scripts/state.gd'

# Particle effect that emits once the player lands.
const LandingPuff := preload('res://sfx/LandingPuff.tscn')

func enter(player: Player, previous_state: int) -> void:
    # Reset velocity.
    player.velocity = Vector2.ZERO

    # Stop attack animation, in case we were attacking in previous state.
    # TODO: Don't do this if previous state was JUMP (otherwise, attacks that
    #       start near the apex of a jump immediately get cancelled).
    player.stop_attack()

    # Play fall animation.
    player.get_animation_player().play('fall')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> int:
    if event.is_action_pressed('player_attack'):
        player.start_attack()
        player.get_animation_player().queue('fall')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return player.State.DASH
    elif event.is_action_pressed('player_jump') and player.can_jump():
        return player.State.DOUBLE_JUMP

    return player.State.NO_CHANGE

func update(player: Player, delta: float) -> int:
    # Once we hit the ground, emit the landing puff and switch to 'idle' state.
    if player.is_on_ground():
        Globals.spawn_particles(LandingPuff.instance(), player)
        return player.State.IDLE

    # Move left or right.
    var input_direction = Globals.get_input_direction()
    if input_direction != 0:
        player.set_player_direction(input_direction)
    player.velocity.x = input_direction * player.MOVEMENT_SPEED

    # Fall.
    player.velocity.y += player.GRAVITY * delta

    player.move(player.velocity)

    return player.State.NO_CHANGE