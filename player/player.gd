extends KinematicBody2D
class_name Player

signal player_state_changed

# The possible states that the player can be in. The NO_CHANGE state is reserved
# for states indicating that the current state should not be changed and does
# not itself constitute a valid player state.
enum State {
	NO_CHANGE,
	IDLE,
	WALK,
	JUMP,
	FALL,
	DASH,
}

# Maps State enum to corresponding state scripts.
onready var STATES = {
	State.IDLE: $States/Idle,
	State.WALK: $States/Walk,
	State.JUMP: $States/Jump,
	State.FALL: $States/Fall,
	State.DASH: $States/Dash,
}

var current_state: Node = null

# The speed at which the player can move the character left and right, measured
# in pixels per second.
var MOVEMENT_SPEED: float = 6 * Globals.TILE_SIZE_PIXELS

# The min/max jump heights the player can achieve in pixels. Releasing the jump
# button early will "cut" the jump somewhere between these two values, allowing
# for variable-height jumps.
var MAX_JUMP_HEIGHT: float = 3.50 * Globals.TILE_SIZE_PIXELS
var MIN_JUMP_HEIGHT: float = 0.50 * Globals.TILE_SIZE_PIXELS

# The duration of the max-height jump in seconds from ground to peak.
var JUMP_DURATION: float = 0.4

# The downward speed applied to the player when falling, measured in pixels per
# second. This is calculated using basic kinematics with MAX_JUMP_HEIGHT and 
# JUMP_DURATION. Note that "gravity" is a bit of a misnomer here, since we do
# not actually accelerate while falling, and rather fall at a constant speed.
var GRAVITY: float = 2 * MAX_JUMP_HEIGHT / pow(JUMP_DURATION, 2)

# The minimum and maximum y-axis velocities achievable by the player when
# jumping. The default jump velocity is MAX_JUMP_VELOCITY, but if the player
# releases the jump button during a jump, the velocity will "cut" and be reduced
# to MIN_JUMP_VELOCITY. This allows for variable-height jumps.
var MIN_JUMP_VELOCITY: float = -sqrt(2 * GRAVITY * MIN_JUMP_HEIGHT)
var MAX_JUMP_VELOCITY: float = -sqrt(2 * GRAVITY * MAX_JUMP_HEIGHT)

# The amount of time to wait after completing a dash before dashing again.
const DASH_COOLDOWN: float = 0.30

# The original position of the attack anchor node relative to the parent.
onready var ORIGINAL_ATTACK_HITBOX_POS: Vector2 = $AttackHitbox.get_position()

# The original position of the camera anchor node relative to the parent.
onready var ORIGINAL_CAMERA_ANCHOR_POS: Vector2 = $CameraAnchor.get_position()

# Keep track of the current room the player is in, as well as the previous room
# the player was in, to assist in room transitions.
var prev_room = null
var curr_room = null

func _ready() -> void:
	# Create a dash cooldown timer.
	$DashCooldown.wait_time = DASH_COOLDOWN
	$DashCooldown.one_shot = true
	
	# Begin in fall state
	current_state = STATES[State.FALL]
	_change_state(State.FALL)
	
	# Initialize current room
	curr_room = get_parent().get_node('Rooms/FactoryEntrance')
	prev_room = curr_room
	get_camera().fit_camera_limits_to_room(curr_room)
	
func _input(event: InputEvent) -> void:
	var new_state = current_state.handle_input(self, event)
	if new_state != State.NO_CHANGE:
		_change_state(new_state)
	
func _physics_process(delta: float) -> void:
	var new_state = current_state.update(self, delta)
	if new_state != State.NO_CHANGE:
		_change_state(new_state)
	
# Change from one state in the state machine to another.
func _change_state(new_state: int) -> void:
	current_state.exit(self)
	current_state = STATES[new_state]
	current_state.enter(self)
	
	emit_signal('player_state_changed', current_state.get_name())
	
func is_on_ground() -> bool:
	return .is_on_floor()
	
func is_in_air() -> bool:
	return not is_on_ground()
	
func start_attack() -> void:
	$AnimationPlayer.play('attack')
	
# Flush animation queue and make attack sprite invisible so that we can cancel
# attack animations cleanly.
func stop_attack() -> void:
	$AnimationPlayer.clear_queue()
	$AttackHitbox/Sprite.set_visible(false)
	
func get_animation_player() -> AnimationPlayer:
	return $AnimationPlayer as AnimationPlayer
	
func get_camera() -> Camera2D:
	return $CameraAnchor/Camera2D as Camera2D
	
func get_dash_cooldown_timer() -> Timer:
	return $DashCooldown as Timer
	
func get_player_direction() -> int:
	return -1 if $Sprite.flip_h else 1
	
func set_player_direction(direction: int) -> void:
	# Flip player sprite.
	$Sprite.flip_h = (direction == -1)
	
	# Mirror attack hitbox on y-axis.
	if direction in [-1, 1]:
		$AttackHitbox.position.x = ORIGINAL_ATTACK_HITBOX_POS.x * direction
	$AttackHitbox/Sprite.flip_h = (direction == -1)
	
	# Flip camera pivot.
	if direction in [-1, 1]:
		$CameraAnchor.position.x = ORIGINAL_CAMERA_ANCHOR_POS.x * direction
	
# Pause/resume processing for player node specifically. Used during room
# transitions.
func pause() -> void:
	set_physics_process(false)
	set_process_input(false)
	
	$AnimationPlayer.stop(false)
	
	$States/Dash/DashDuration.paused = true
	$States/Dash/DashEcho.paused = true
	$DashCooldown.paused = true
func unpause() -> void:
	set_physics_process(true)
	set_process_input(true)
	
	$AnimationPlayer.play()
	
	$States/Dash/DashDuration.paused = false
	$States/Dash/DashEcho.paused = false
	$DashCooldown.paused = false
