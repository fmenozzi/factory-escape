extends 'res://scripts/state.gd'

# Particle effect that emits once the player lands.
const LandingPuff := preload('res://sfx/LandingPuff.tscn')

# Max falling speed the player can achieve in pixels per second.
var TERMINAL_VELOCITY: float = 20 * Globals.TILE_SIZE

func enter(player: Player, previous_state_dict: Dictionary) -> void:
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

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_pressed('player_attack'):
        player.start_attack()
        player.get_animation_player().queue('fall')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return {'new_state': player.State.DASH}
    elif event.is_action_pressed('player_jump'):
        if player.is_near_wall_front() or player.is_near_wall_back():
            # Wall jump.
            return {'new_state': player.State.WALL_JUMP}
        elif player.can_jump():
            # Double jump.
            return {'new_state': player.State.DOUBLE_JUMP}
    elif event.is_action_pressed('player_grapple'):
        if player.get_closest_grapple_point() != Vector2.ZERO:
            return {'new_state': player.State.GRAPPLE}

    return {'new_state': player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once we hit the ground, emit the landing puff and switch to 'idle' state.
    if player.is_on_ground():
        Globals.spawn_particles(LandingPuff.instance(), player)
        return {'new_state': player.State.IDLE}

    # Start wall sliding if we're on a wall.
    if player.is_on_wall():
        return {'new_state': player.State.WALL_SLIDE}

    # Move left or right.
    var input_direction = Globals.get_input_direction()
    if input_direction != 0:
        player.set_player_direction(input_direction)
    player.velocity.x = input_direction * player.MOVEMENT_SPEED

    # Fall.
    player.velocity.y =\
        min(player.velocity.y + player.GRAVITY * delta, TERMINAL_VELOCITY)

    player.move(player.velocity)

    return {'new_state': player.State.NO_CHANGE}
