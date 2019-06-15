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

# Vector denoting the 2D movement to be applied to the player during each 
# update() call, measured in pixels per second.
var velocity: Vector2 = Vector2()

const DashEcho = preload('res://player/DashEcho.tscn')

func _ready() -> void:
	# Set up dash duration timer.
	$DashDuration.wait_time = DASH_DURATION
	$DashDuration.one_shot = true
	
	# Set up dash echo timer.
	$DashEcho.wait_time = DASH_ECHO_DELAY
	
	# Calculate dash speed from the specified dash distance and duration.
	DASH_SPEED = DASH_DISTANCE / DASH_DURATION
	
func enter(player: Player) -> void:
	# Reset dash duration, dash cooldown, and dash echo timers.
	$DashDuration.start()
	$DashEcho.connect('timeout', self, '_on_dash_echo_timeout', [player])
	$DashEcho.start()
	player.get_dash_cooldown_timer().stop()
	
	# Reset velocity.
	velocity = Vector2()
	
	# Play dash animation.
	player.get_animation_player().play('dash')
	
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
	velocity.x = player.get_player_direction() * DASH_SPEED
	velocity = player.move_and_slide(velocity, Globals.FLOOR_NORMAL)
		
	return player.State.NO_CHANGE
	
func _on_dash_echo_timeout(player: Player) -> void:
	# TODO: Configure dash in terms of how many echoes to emit and consider not
	#       emitting an echo right under the player.
	
	var echo = DashEcho.instance()
	player.get_parent().add_child(echo)
	echo.flip_h = (player.get_player_direction() == -1)
	# TODO: Why is there this 8 pixel offset?
	echo.set_global_position(player.get_global_position() + Vector2(0, -8))