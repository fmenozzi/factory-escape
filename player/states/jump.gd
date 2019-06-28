extends 'res://scripts/state.gd'

# Vector denoting the 2D movement to be applied to the player during each 
# update() call, measured in pixels per second.
var velocity := Vector2()

func enter(player: Player) -> void:
	# Set initial jump velocity to max jump velocity (releasing the jump button
	# will cause the velocity to "cut", allowing for variable-height jumps).
	velocity.y = player.MAX_JUMP_VELOCITY
	
	# Stop attack animation, in case we were attacking in previous state.
	player.stop_attack()
	
	# Play jump animation.
	player.get_animation_player().play('jump')
	
func exit(player: Player) -> void:
	pass
	
func handle_input(player: Player, event: InputEvent) -> int:
	# "Jump cut" if the jump button is released.
	if event.is_action_released('player_jump') and \
	   velocity.y < player.MIN_JUMP_VELOCITY:
		velocity.y = player.MIN_JUMP_VELOCITY
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
	if velocity.y >= 0:
		return player.State.FALL
		
	# Move left or right.
	var input_direction = Globals.get_input_direction()
	if input_direction != 0:
		player.set_player_direction(input_direction)
	velocity.x = input_direction * player.MOVEMENT_SPEED
		
	# Move due to gravity.
	velocity.y += player.GRAVITY * delta
	velocity = player.move_and_slide(velocity, Globals.FLOOR_NORMAL)
	
	return player.State.NO_CHANGE