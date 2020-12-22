extends 'res://actors/player/states/player_state.gd'

var _attack_again := false
var _attack_is_connecting := false

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset velocity.
    player.velocity = Vector2.ZERO

    # If present, incorporate existing player velocity. Zero out the x-component
    # so that we ensure we only move horizontally when airborne (as detected in
    # update() below).
    if 'velocity' in previous_state_dict:
        player.velocity = previous_state_dict['velocity']
        player.velocity.x = 0

    player.start_attack(player.get_attack_manager().get_next_attack_animation())

    _attack_again = false

func exit(player: Player) -> void:
    player.stop_attack()

    _attack_is_connecting = false

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    if event.is_action_pressed('player_attack'):
        if player.get_attack_manager().can_attack():
            _attack_again = true
    elif event.is_action_released('player_jump'):
        # "Jump cut" if the jump button is released.
        player.velocity.y = max(
            player.velocity.y, physics_manager.get_min_jump_velocity())

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    if not player.get_animation_player().is_playing():
        if _attack_again:
            return {
                'new_state': Player.State.ATTACK,
                'velocity': player.velocity,
            }
        elif player.is_in_air():
            return {
                'new_state': Player.State.FALL,
                'velocity': player.velocity,
            }
        else:
            return {'new_state': Player.State.IDLE}

    # Move left or right if airborne.
    if player.is_in_air():
        var input_direction = player.get_input_direction()
        if input_direction != Util.Direction.NONE:
            player.set_direction(input_direction)
        player.velocity.x = input_direction * physics_manager.get_movement_speed()

    # Fall.
    if not _attack_is_connecting:
        player.velocity.y = min(
            player.velocity.y + physics_manager.get_gravity() * delta,
            physics_manager.get_terminal_velocity())

    if not _attack_is_connecting:
        player.move(player.velocity)

    return {'new_state': Player.State.NO_CHANGE}

func _on_attack_connected(enemy_hurtbox: Area2D) -> void:
    _attack_is_connecting = true
