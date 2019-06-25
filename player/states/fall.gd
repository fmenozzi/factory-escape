extends 'res://scripts/state.gd'

# Particle effect that emits once the player lands.
const LandingPuff := preload('res://sfx/LandingPuff.tscn')

# Vector denoting the 2D movement to be applied to the player during each 
# update() call, measured in pixels per second.
var velocity := Vector2()

func enter(player: Player) -> void:
	# Reset velocity.
	velocity = Vector2()
	
	# Stop attack animation, in case we were attacking in previous state.
	# TODO: Don't do this if previous state was JUMP (otherwise, attacks that
	#       start near the apex of a jump immediately get cancelled).
	player.stop_attack()
	
	# Play fall animation.
	player.get_animation_player().play('fall')
	
func exit(player: Player) -> void:
	pass
	
func handle_input(player: Player, event: InputEvent) -> int:
	if event.is_action_pressed('player_attack'):
		player.start_attack()
		player.get_animation_player().queue('fall')
	elif event.is_action_pressed('player_dash'):
		# Only dash if the cooldown is done.
		if player.get_dash_cooldown_timer().is_stopped():
			return player.State.DASH
		
	return player.State.NO_CHANGE
	
func update(player: Player, delta: float) -> int:
	# Once we hit the ground, emit the landing puff and switch to 'idle' state.
	if player.is_on_ground():
		var landing_puff = LandingPuff.instance()
		player.add_child(landing_puff)

		var particles_manager := OneShotParticlesManager.new()
		player.add_child(particles_manager)
		particles_manager.start(landing_puff)

		return player.State.IDLE
		
	# Move left or right.
	var input_direction = Globals.get_input_direction()
	if input_direction != 0:
		player.set_player_direction(input_direction)
	velocity.x = input_direction * player.MOVEMENT_SPEED
	
	# Fall.
	velocity.y += player.GRAVITY * delta
	velocity = player.move_and_slide(velocity, Globals.FLOOR_NORMAL)
	
	return player.State.NO_CHANGE