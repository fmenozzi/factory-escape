extends 'res://actors/player/states/player_state.gd'

# If we fall for longer than this duration, transition to hard landing state
# instead of idle state upon touching the ground.
const HARD_LANDING_FALL_DURATION: float = 1.0

# If the player presses jump within this time period of entering the fall state
# from the idle/walk state, allow the jump to proceed even though they've
# already fallen off the edge.
const COYOTE_TIME_DURATION: float = 0.1

# If true, transition to jump state immediately upon landing (buffer jump). This
# is only enabled if the player presses the jump button while falling (when
# unable to jump normally) and the player is close to the ground (as determined
# by the jump buffer raycast attached to the player).
var _buffer_jump_enabled := false

# If true, transition to dash state immediately upon landing (buffer dash). This
# is only enabled if the player presses the dash button while falling (when
# unable to dash normally) and the player is close to the ground (as determined
# by the dash buffer raycast attached to the player).
var _buffer_dash_enabled := false

onready var _fall_time_stopwatch: Stopwatch = $FallTimeStopwatch
onready var _coyote_timer: Timer = $CoyoteTimer

func _ready() -> void:
    _coyote_timer.one_shot = true
    _coyote_timer.wait_time = COYOTE_TIME_DURATION

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    # Reset velocity.
    player.velocity = Vector2.ZERO

    # Let attack animation play out before switching to fall animation.
    if player.is_attacking():
        player.get_animation_player().clear_queue()
        player.get_animation_player().queue('fall')
    else:
        player.get_animation_player().play('fall')

    # Treat falling off a ledge as consuming a jump (i.e. can only jump again if
    # we have the double jump). Also, start the coyote timer to allow for jumps
    # after walking off a ledge.
    var previous_state: int = previous_state_dict['previous_state']
    if not previous_state in [
        Player.State.JUMP,
        Player.State.DOUBLE_JUMP,
        Player.State.DASH,
        Player.State.STAGGER,
    ]:
        var jump_manager := player.get_jump_manager()
        jump_manager.reset_jump()
        jump_manager.consume_jump()

        _coyote_timer.start()

    # Start the fall time stopwatch.
    _fall_time_stopwatch.start()

    _buffer_jump_enabled = false
    _buffer_dash_enabled = false

func exit(player: Player) -> void:
    # In case we exit the fall state before the previously-playing attack
    # animation finishes, stop the attack, which has the effect of both flushing
    # the animation queue and hiding the attack sprite.
    if player.is_attacking():
        player.stop_attack()

    _coyote_timer.stop()

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    var jump_manager := player.get_jump_manager()
    var dash_manager := player.get_dash_manager()

    if event.is_action_pressed('player_attack'):
        if Input.is_action_pressed("player_move_up"):
            player.start_attack('attack_up')
        else:
            player.start_attack('attack')
        player.get_animation_player().queue('fall')
    elif event.is_action_pressed('player_dash'):
        if dash_manager.can_dash():
            return {'new_state': Player.State.DASH}
        elif dash_manager.get_dash_buffer_raycast().is_colliding():
            _buffer_dash_enabled = true
    elif event.is_action_pressed('player_jump'):
        if player.is_near_wall_front() or player.is_near_wall_back():
            # Wall jump.
            return {'new_state': Player.State.WALL_JUMP}
        elif not _coyote_timer.is_stopped():
            # Coyote time jump.
            jump_manager.reset_jump()
            return {'new_state': Player.State.JUMP}
        elif jump_manager.can_jump():
            # Double jump.
            return {'new_state': Player.State.DOUBLE_JUMP}
        elif jump_manager.get_jump_buffer_raycast().is_colliding():
            # Enable buffer jump if the player is close to the ground and
            # presses the jump button (and is unable to otherwise jump).
            _buffer_jump_enabled = true
    elif event.is_action_pressed('player_grapple'):
        var next_grapple_point := player.get_next_grapple_point()
        if next_grapple_point != null:
            return {
                'new_state': Player.State.GRAPPLE,
                'grapple_point': next_grapple_point,
            }

    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    var physics_manager := player.get_physics_manager()

    # Once we hit the ground, emit the landing puff and either switch to idle,
    # "hard land", or perform a buffer action.
    if player.is_on_ground():
        player.emit_dust_puff()
        if _fall_time_stopwatch.stop() >= HARD_LANDING_FALL_DURATION:
            return {'new_state': Player.State.HARD_LANDING}
        elif _buffer_jump_enabled:
            player.get_jump_manager().reset_jump()
            return {'new_state': Player.State.JUMP}
        elif _buffer_dash_enabled:
            return {'new_state': Player.State.DASH}
        else:
            return {'new_state': Player.State.IDLE}

    # Start wall sliding if we're on a wall.
    if player.is_on_wall():
        return {'new_state': Player.State.WALL_SLIDE}

    # Move left or right.
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
