extends 'res://scripts/state.gd'

# The distance covered by the dash in pixels.
var DASH_DISTANCE: float = 4 * Globals.TILE_SIZE_PIXELS

# The duration of the dash in seconds.
const DASH_DURATION: float = 0.20

# The speed at which the player moves when dashing, measured in pixels per
# second and calculated based on dash duration and dash distance.
var DASH_SPEED: float

# The delay between emissions of the dash echo.
var DASH_ECHO_DELAY: float = 0.05

const DashEcho = preload('res://player/DashEcho.tscn')
const DashPuff = preload('res://sfx/DashPuff.tscn')

func _ready() -> void:
	# Set up dash duration timer.
	$DashDuration.wait_time = DASH_DURATION
	$DashDuration.one_shot = true
	
	# Set up dash echo timer.
	$DashEcho.wait_time = DASH_ECHO_DELAY
	
	# Calculate dash speed from the specified dash distance and duration.
	DASH_SPEED = DASH_DISTANCE / DASH_DURATION
	
func enter(player: Player, previous_state: int) -> void:
	# Reset dash duration, dash cooldown, and dash echo timers.
	$DashDuration.start()
	$DashEcho.connect('timeout', self, '_on_dash_echo_timeout', [player])
	$DashEcho.start()
	player.get_dash_cooldown_timer().stop()

	# Instance a new dash puff on every dash.
	var dash_puff = DashPuff.instance()
	dash_puff.position = Vector2(0, -8)
	var dash_puff_speed := abs(dash_puff.process_material.initial_velocity)
	dash_puff.process_material.initial_velocity =\
		dash_puff_speed * player.get_player_direction()

	Globals.spawn_particles(dash_puff, player)

	# Reset player velocity.
	player.velocity = Vector2.ZERO
	
	# Play dash animation.
	player.get_animation_player().play('dash')

	# Consume the dash until it is reset be e.g. hitting the ground. Also,
	# ensure that we get no more than one jump after a dash if we e.g. dash off
	# of a ledge. We're really only doing this because Hollow Knight does it,
	# and I can't really think of a reason why this limitation exists; maybe to
	# limit player mobility given the pogo mechanic? That is, some platforming
	# sections might have been harder to design if the player could double jump
	# after a dash/pogo. Might revisit this if it becomes incompatible with this
	# game's eventual design.
	player.consume_dash()
	if player.can_jump():
		player.reset_jump()
		player.consume_jump()
	
func exit(player: Player) -> void:
	# Start the cooldown timer once the dash finishes.
	player.get_dash_cooldown_timer().start()
	
	# Stop the dash echo timer.
	$DashEcho.disconnect('timeout', self, '_on_dash_echo_timeout')
	$DashEcho.stop()
	
func handle_input(player: Player, event: InputEvent) -> int:
	return player.State.NO_CHANGE
	
func update(player: Player, delta: float) -> int:
	# Once the dash is complete, we either fall if we're currently airborne or
	# idle otherwise.
	if $DashDuration.is_stopped():
		return player.State.FALL if player.is_in_air() else player.State.IDLE
		
	# Dash in the direction the player is currently facing.
	player.velocity.x = player.get_player_direction() * DASH_SPEED
	player.move(player.velocity)

	return player.State.NO_CHANGE
	
func _on_dash_echo_timeout(player: Player) -> void:
	# TODO: Configure dash in terms of how many echoes to emit and consider not
	#       emitting an echo right under the player.
	
	var echo = DashEcho.instance()
	player.get_parent().add_child(echo)
	echo.flip_h = (player.get_player_direction() == -1)
	# TODO: Why is there this 8 pixel offset?
	echo.set_global_position(player.get_global_position() + Vector2(0, -8))