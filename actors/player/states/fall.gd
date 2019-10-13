extends 'res://scripts/state.gd'

# Particle effect that emits once the player lands.
const LandingPuff := preload('res://sfx/LandingPuff.tscn')

# Max falling speed the player can achieve in pixels per second.
var TERMINAL_VELOCITY: float = 20 * Util.TILE_SIZE

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset velocity.
    player.velocity = Vector2.ZERO

    # Let attack animation play out before switching to fall animation.
    if player.is_attacking():
        player.get_animation_player().clear_queue()
        player.get_animation_player().queue('fall')
    else:
        player.get_animation_player().play('fall')

func exit(player: Player) -> void:
    # In case we exit the fall state before the previously-playing attack
    # animation finishes, stop the attack, which has the effect of both flushing
    # the animation queue and hiding the attack sprite.
    if player.is_attacking():
        player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    if event.is_action_pressed('player_attack'):
        player.start_attack()
        player.get_animation_player().queue('fall')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_jump'):
        if player.is_near_wall_front() or player.is_near_wall_back():
            # Wall jump.
            return {'new_state': Player.State.WALL_JUMP}
        elif player.can_jump():
            # Double jump.
            return {'new_state': Player.State.DOUBLE_JUMP}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE_START,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    # Once we hit the ground, emit the landing puff and switch to 'idle' state.
    if player.is_on_ground():
        Util.spawn_particles(LandingPuff.instance(), player)
        return {'new_state': Player.State.IDLE}

    # Start wall sliding if we're on a wall.
    if player.is_on_wall():
        return {'new_state': Player.State.WALL_SLIDE}

    # Move left or right.
    var input_direction = Util.get_input_direction()
    if input_direction != Util.Direction.NONE:
        player.set_direction(input_direction)
    player.velocity.x = input_direction * player.MOVEMENT_SPEED

    # Fall.
    player.velocity.y =\
        min(player.velocity.y + player.GRAVITY * delta, TERMINAL_VELOCITY)

    player.move(player.velocity)

    return {'new_state': Player.State.NO_CHANGE}
