extends 'res://actors/player/states/player_state.gd'

# Timer for controlling how long during the wall jump the player does not have
# directional control.
onready var _fixed_velocity_timer: Timer = $FixedVelocityTimer

# Timer for controlling how long the player must wait before the jump cut takes
# effect. This is primarily to prevent the player from spamming jump while wall
# sliding to scale walls very quickly.
onready var _jump_cut_timer: Timer = $JumpCutTimer

func _ready() -> void:
    _fixed_velocity_timer.one_shot = true
    _fixed_velocity_timer.wait_time = 0.3

    _jump_cut_timer.one_shot = true
    _jump_cut_timer.wait_time = 0.1

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # TODO: Add wall jump puff.
    player.emit_dust_puff()

    # Set initial jump velocity to max jump velocity (releasing the jump button
    # will cause the velocity to "cut", allowing for variable-height jumps).
    player.velocity.y = player.get_physics_manager().get_max_jump_velocity()

    # Flip the player to face away from the wall.
    player.set_direction(player.get_wall_jump_manager().get_wall_normal_front().x)

    # Consume the jump until it is reset by e.g. hitting the ground.
    player.get_jump_manager().consume_jump()

    # Play jump animation.
    player.get_animation_player().play('jump')

    player.get_sound_manager().play(PlayerSoundManager.Sounds.JUMP)

    # Start the timers.
    _fixed_velocity_timer.start()
    _jump_cut_timer.start()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()
    var grapple_manager := player.get_grapple_manager()
    var wall_jump_manager := player.get_wall_jump_manager()

    if event.is_action_released('player_jump') and _jump_cut_timer.is_stopped():
        _jump_cut(player)
    elif event.is_action_pressed('player_jump'):
        if _fixed_velocity_timer.is_stopped():
            # Once we regain control, either wall jump or double jump, depending
            # on whether we're near a wall.
            if wall_jump_manager.is_near_wall_front() or wall_jump_manager.is_near_wall_back():
                if wall_jump_manager.can_wall_jump():
                    return {'new_state': Player.State.WALL_JUMP}
            elif jump_manager.can_jump():
                return {'new_state': Player.State.DOUBLE_JUMP}
    elif event.is_action_pressed('player_attack'):
        player.start_attack()
        player.get_animation_player().queue('jump')
    elif event.is_action_pressed('player_dash') and dash_manager.can_dash():
        return {'new_state': Player.State.DASH}
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := grapple_manager.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    # Switch to 'fall' state once we reach apex of jump.
    if player.velocity.y >= 0:
        return {'new_state': Player.State.FALL}

    if not Input.is_action_pressed('player_jump'):
        if _jump_cut_timer.is_stopped():
            _jump_cut(player)

    # Until the timer is done, fix the x-velocity to a constant amount so that
    # the player travels up and away from the wall. After the timer times out,
    # the player is given full control of the character.
    var direction := player.get_direction()
    if _fixed_velocity_timer.is_stopped():
        var input_direction = player.get_input_direction()
        if input_direction != Util.Direction.NONE:
            player.set_direction(input_direction)
            direction = input_direction
    player.velocity.x = direction * physics_manager.get_movement_speed()

    # Move due to gravity.
    player.velocity.y += physics_manager.get_gravity() * delta

    player.move(player.velocity)

    return {'new_state': Player.State.NO_CHANGE}

# "Jump cut" if the jump button is released. This will also stop the
# fixed velocity timer and therefore return control to the player.
func _jump_cut(player: Player) -> void:
    player.velocity.y = max(
        player.velocity.y, player.get_physics_manager().get_min_jump_velocity())
    _fixed_velocity_timer.stop()
