extends 'res://scripts/state.gd'

func enter(player: Player, previous_state: int) -> void:
	# Reset player velocity.
	player.velocity = Vector2.ZERO
	
	# Stop attack animation, in case we were attacking in previous state.
	player.stop_attack()
	
	# Play walk animation.
	player.get_animation_player().play('walk')
	
func exit(player: Player) -> void:
	pass
	
func handle_input(player: Player, event: InputEvent) -> int:
	if event.is_action_pressed('player_jump') and player.can_jump():
		return player.State.JUMP
	elif event.is_action_pressed('player_attack'):
		# Play attack animation before returning to walk animation.
		player.start_attack()
		player.get_animation_player().queue('walk')
	elif event.is_action_pressed('player_dash') and player.can_dash():
		# Only dash if the cooldown is done.
		if player.get_dash_cooldown_timer().is_stopped():
			return player.State.DASH
	
	return player.State.NO_CHANGE
	
func update(player: Player, delta: float) -> int:
	# Change to idle state if we stop moving.
	var input_direction = Globals.get_input_direction()
	if input_direction == 0:
		return player.State.IDLE
		
	# If we've walked off a platform, start falling.
	if player.is_in_air():
		return player.State.FALL

	player.set_player_direction(input_direction)

	# Move left or right. Add in sufficient downward movement so that
	# is_on_floor() detects collisions with the floor and doesn't erroneously
	# report that we're in the air.
	player.move(Vector2(input_direction * player.MOVEMENT_SPEED, 10))

	return player.State.NO_CHANGE