extends 'res://actors/player/states/player_state.gd'

var _attack_again := false
var _attack_is_connecting := false

enum TransitionTo {
    NONE,
    JUMP,
    DASH,
    GRAPPLE,
}
var _transition_to: int = TransitionTo.NONE
var _next_grapple_point: GrapplePoint = null

var _audio_stream_player: AudioStreamPlayer = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset velocity.
    player.velocity = Vector2.ZERO

    # If present, incorporate existing player velocity. Zero out the x-component
    # so that we ensure we only move horizontally when airborne (as detected in
    # update() below).
    if 'velocity' in previous_state_dict:
        player.velocity = previous_state_dict['velocity']
        player.velocity.x = 0

    var next_attack_animation := player.get_attack_manager().get_next_attack_animation()
    _audio_stream_player = player.get_sound_manager().get_player(PlayerSoundManager.Sounds.ATTACK)
    match next_attack_animation:
        'attack_1':
            _audio_stream_player.pitch_scale = 1.0

        'attack_2':
            _audio_stream_player.pitch_scale = 1.1

        'attack_3':
            _audio_stream_player.pitch_scale = 1.2
    player.start_attack(next_attack_animation)
    _audio_stream_player.play()

    _attack_again = false
    _transition_to = TransitionTo.NONE

func exit(player: Player) -> void:
    player.stop_attack()

    _audio_stream_player.pitch_scale = 1.0

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
    elif event.is_action_pressed('player_jump'):
        if player.get_jump_manager().can_jump():
            _transition_to = TransitionTo.JUMP
    elif event.is_action_pressed('player_dash'):
        if player.get_dash_manager().can_dash():
            _transition_to = TransitionTo.DASH
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_grapple_manager().get_next_grapple_point()
        if next_grapple_point != null:
            _next_grapple_point = next_grapple_point
            _transition_to = TransitionTo.GRAPPLE

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    player.velocity.x = 0

    if _attack_is_connecting:
        player.velocity.y = 0

    if not player.get_animation_player().is_playing():
        match _transition_to:
            TransitionTo.JUMP:
                if Input.is_action_pressed('player_jump'):
                    # Insist that the jump button is being held so that the
                    # player can jump cut later by releasing.
                    return {'new_state': Player.State.JUMP}

            TransitionTo.DASH:
                return {'new_state': Player.State.DASH}

            TransitionTo.GRAPPLE:
                return {
                    'new_state': Player.State.GRAPPLE,
                    'grapple_point': _next_grapple_point,
                }

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
