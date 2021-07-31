extends 'res://actors/player/states/player_state.gd'

onready var _look_up_down_keyboard_delay_timer: Timer = $LookUpDownKeyboardDelayTimer

var _started_timer := false

func _ready() -> void:
    _look_up_down_keyboard_delay_timer.one_shot = true
    _look_up_down_keyboard_delay_timer.wait_time = 0.5

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset player velocity.
    player.velocity = Vector2.ZERO

    if player.get_health().get_current_health() == 1:
        player.get_animation_player().play('idle_low_health')
    else:
        player.get_animation_player().play('idle')

    _started_timer = false

    # Reset the dash and double jump.
    player.get_dash_manager().reset_dash()
    player.get_jump_manager().reset_jump()

func exit(player: Player) -> void:
    _look_up_down_keyboard_delay_timer.stop()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()
    var grapple_manager := player.get_grapple_manager()

    # Looking up/down on controller happens immediately.
    if event.is_action_pressed('player_look_down_controller'):
        return {
            'new_state': Player.State.LOOK_DOWN,
            'entered_from_controller': true,
        }
    if event.is_action_pressed('player_look_up_controller'):
        return {
            'new_state': Player.State.LOOK_UP,
            'entered_from_controller': true,
        }

    # Looking up/down on keyboard incurs a small delay so that the player can
    # have time to up-attack instead of looking up.
    if event.is_action_pressed('player_look_down_keyboard'):
        if _look_up_down_keyboard_delay_timer.is_stopped():
            _look_up_down_keyboard_delay_timer.start()
            _started_timer = true
    if event.is_action_pressed('player_look_up_keyboard'):
        if _look_up_down_keyboard_delay_timer.is_stopped():
            _look_up_down_keyboard_delay_timer.start()
            _started_timer = true
    if event.is_action_released('player_look_down_keyboard'):
        _look_up_down_keyboard_delay_timer.stop()
    if event.is_action_released('player_look_up_keyboard'):
        _look_up_down_keyboard_delay_timer.stop()

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

    if player.get_input_direction() != Util.Direction.NONE:
        return {'new_state': Player.State.WALK}

    if _look_up_down_keyboard_delay_timer.is_stopped() and _started_timer:
        if Input.is_action_pressed('player_look_down_keyboard'):
            return {
                'new_state': Player.State.LOOK_DOWN,
                'entered_from_controller': false,
            }
        if Input.is_action_pressed('player_look_up_keyboard'):
            return {
                'new_state': Player.State.LOOK_UP,
                'entered_from_controller': false,
            }

    # It's possible to inch off a ledge and no longer be on the ground directly
    # from the idle state (i.e. without having to first transition to the walk
    # state), so include direct transition to fall state. Otherwise, the slight
    # downward movement below will cause us to fall very slowly in the air.
    if player.is_in_air():
        return {'new_state': Player.State.FALL}

    # Apply slight downward movement. This is important mostly for ensuring that
    # move_and_slide() is called on every frame, which updates collisions. This
    # allows us to e.g. idle next to a wall (without pressing into it) and have
    # is_on_wall() correctly report that we're NOT on a wall, which is important
    # for not triggering wall slide when jumping up from idling next to a wall.
    player.move(Vector2(0, player.get_slight_downward_move()))

    return {'new_state': Player.State.NO_CHANGE}
