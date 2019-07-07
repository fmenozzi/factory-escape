extends "res://scripts/state.gd"

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

func enter(player: Player, previous_state: int) -> void:
    # TODO: Add wall jump puff.

    # Set initial jump velocity to max jump velocity (releasing the jump button
    # will cause the velocity to "cut", allowing for variable-height jumps).
    player.velocity.y = player.MAX_JUMP_VELOCITY

    # Flip the player to face away from the wall.
    player.set_player_direction(-1 * player.get_player_direction())

    # Consume the jump until it is reset by e.g. hitting the ground.
    player.consume_jump()

    # Play jump animation.
    player.get_animation_player().play('jump')

    # Start the timers.
    _fixed_velocity_timer.start()
    _jump_cut_timer.start()

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> int:
    if event.is_action_released('player_jump') and _jump_cut_timer.is_stopped():
        _jump_cut(player)
    elif event.is_action_pressed('player_jump') and player.can_jump():
        # Double jump once we have control again.
        if _fixed_velocity_timer.is_stopped():
            return player.State.DOUBLE_JUMP
    elif event.is_action_pressed('player_attack'):
        player.start_attack()
        player.get_animation_player().queue('jump')
    elif event.is_action_pressed('player_dash') and player.can_dash():
        # Only dash if the cooldown is done.
        if player.get_dash_cooldown_timer().is_stopped():
            return player.State.DASH

    return player.State.NO_CHANGE

func update(player: Player, delta: float) -> int:
    # Switch to 'fall' state once we reach apex of jump.
    if player.velocity.y >= 0:
        return player.State.FALL

    if not Input.is_action_pressed('player_jump'):
        if _jump_cut_timer.is_stopped():
            _jump_cut(player)

    # Until the timer is done, fix the x-velocity to a constant amount so that
    # the player travels up and away from the wall. After the timer times out,
    # the player is given full control of the character.
    var direction := 0
    if not _fixed_velocity_timer.is_stopped():
        direction = player.get_player_direction()
    else:
        var input_direction = Globals.get_input_direction()
        if input_direction != 0:
            player.set_player_direction(input_direction)
        direction = input_direction
    player.velocity.x = direction * player.MOVEMENT_SPEED

    # Move due to gravity.
    player.velocity.y += player.GRAVITY * delta

    player.move(player.velocity)

    return player.State.NO_CHANGE

# "Jump cut" if the jump button is released. This will also stop the
# fixed velocity timer and therefore return control to the player.
func _jump_cut(player: Player) -> void:
    player.velocity.y = max(player.velocity.y, player.MIN_JUMP_VELOCITY)
    _fixed_velocity_timer.stop()