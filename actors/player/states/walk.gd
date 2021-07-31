extends 'res://actors/player/states/player_state.gd'

var _player: Player = null

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    _player = player

    # Reset player velocity.
    player.velocity = Vector2.ZERO

    # Play walk animation.
    player.get_animation_player().play('walk')

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()
    var grapple_manager := player.get_grapple_manager()

    if event.is_action_pressed('player_jump') and jump_manager.can_jump():
        return {'new_state': Player.State.JUMP}
    elif event.is_action_pressed('player_attack'):
        if Input.is_action_pressed('player_move_up'):
            return {'new_state': Player.State.ATTACK_UP}
        elif player.get_attack_manager().can_attack():
            return {'new_state': Player.State.ATTACK}
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
        return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := grapple_manager.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE,
                'grapple_point': next_grapple_point,
            }
    elif event.is_action_pressed('player_heal'):
        if player.get_health_pack_manager().can_heal():
            return {'new_state': Player.State.HEAL}
        else:
            player.emit_signal('player_heal_attempted_no_health_packs')

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    if player.is_on_spring_head():
        return {'new_state': Player.State.SPRING_JUMP}

    # Change to idle state if we stop moving.
    var input_direction = player.get_input_direction()
    if input_direction == Util.Direction.NONE:
        return {'new_state': Player.State.IDLE}

    # If we've walked off a platform, start falling.
    if player.is_in_air():
        return {'new_state': Player.State.FALL}

    player.set_direction(input_direction)

    # Move left or right. Add in sufficient downward movement so that
    # is_on_floor() detects collisions with the floor and doesn't erroneously
    # report that we're in the air.
    var speed := player.get_physics_manager().get_movement_speed()
    player.move(Vector2(input_direction * speed, player.get_slight_downward_move()))

    return {'new_state': Player.State.NO_CHANGE}

func _emit_walk_sound() -> void:
    _player.get_sound_manager().play(PlayerSoundManager.Sounds.WALK)
