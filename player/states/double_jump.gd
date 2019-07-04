extends 'res://scripts/state.gd'

# Since we don't want the double jump to be as strong as the initial jump, use
# this multiplier to adjust the new jump height and recalculate max jump
# velocity. Note that we only change the jump velocity and not the gravity,
# which ensures that the player falls at the same speed as a single jump.
const JUMP_HEIGHT_MULTIPLIER: float = 0.70

var NEW_MAX_JUMP_VELOCITY: float

func enter(player: Player, previous_state: int) -> void:
	# Recalculate max jump velocity to account for reduced jump height.
	var new_max_jump_height := JUMP_HEIGHT_MULTIPLIER * player.MAX_JUMP_HEIGHT
	NEW_MAX_JUMP_VELOCITY = -sqrt(2 * player.GRAVITY * new_max_jump_height)

	# Set initial jump velocity to max jump velocity (releasing the jump button
	# will cause the velocity to "cut", allowing for variable-height jumps).
	player.velocity.y = NEW_MAX_JUMP_VELOCITY

	# Stop attack animation, in case we were attacking in previous state.
	player.stop_attack()

	# Play jump animation.
	player.get_animation_player().play('jump')

	# Consume the jump until it is reset by e.g. hitting the ground.
	player.consume_jump()

func exit(player: Player) -> void:
	pass

func handle_input(player: Player, event: InputEvent) -> int:
	if event.is_action_released('player_jump'):
		# "Jump cut" if the jump button is released.
		player.velocity.y = max(player.velocity.y, player.MIN_JUMP_VELOCITY)
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

	# Move left or right.
	var input_direction = Globals.get_input_direction()
	if input_direction != 0:
		player.set_player_direction(input_direction)
	player.velocity.x = input_direction * player.MOVEMENT_SPEED

	# Move due to gravity.
	player.velocity.y += player.GRAVITY * delta

	player.move(player.velocity)

	return player.State.NO_CHANGE