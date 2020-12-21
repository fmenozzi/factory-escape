extends 'res://actors/player/states/player_state.gd'

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset velocity.
    player.velocity = Vector2.ZERO

    # If present, incorporate existing player velocity.
    if 'velocity' in previous_state_dict:
        player.velocity = previous_state_dict['velocity']

    player.start_attack('attack_up')

func exit(player: Player) -> void:
    player.stop_attack()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    if event.is_action_released('player_jump'):
        # "Jump cut" if the jump button is released.
        player.velocity.y = max(
            player.velocity.y, physics_manager.get_min_jump_velocity())

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    if not player.get_animation_player().is_playing():
        if player.is_on_floor():
            return {'new_state': Player.State.IDLE}
        else:
            return {
                'new_state': Player.State.FALL,
                'velocity': player.velocity,
            }

    # Move left or right if airborne.
    if player.is_in_air():
        var input_direction = player.get_input_direction()
        if input_direction != Util.Direction.NONE:
            player.set_direction(input_direction)
        player.velocity.x = input_direction * physics_manager.get_movement_speed()

    # Fall.
    player.velocity.y = min(
        player.velocity.y + physics_manager.get_gravity() * delta,
        physics_manager.get_terminal_velocity())

    player.move(player.velocity)

    return {'new_state': Player.State.NO_CHANGE}
