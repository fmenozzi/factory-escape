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
    DOUBLE_JUMP,
    FALL,
    DASH,
    WALL_SLIDE,
    WALL_JUMP,
}

# Maps State enum to corresponding state scripts.
onready var STATES = {
    State.IDLE:        $States/Idle,
    State.WALK:        $States/Walk,
    State.JUMP:        $States/Jump,
    State.DOUBLE_JUMP: $States/DoubleJump,
    State.FALL:        $States/Fall,
    State.DASH:        $States/Dash,
    State.WALL_SLIDE:  $States/WallSlide,
    State.WALL_JUMP:   $States/WallJump,
}

var current_state: Node = null
var current_state_enum: int = -1

# Vector denoting the 2D movement to be applied to the player during each
# update() call, measured in pixels per second.
var velocity: Vector2 = Vector2.ZERO

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

# The original positions of all "y-axis mirrored" nodes.
var _mirror_y_axis_node_original_positions: Dictionary = {}

# Keep track of the current room the player is in, as well as the previous room
# the player was in, to assist in room transitions.
var prev_room = null
var curr_room = null

var _can_dash: bool = true

var _jumps_remaining: int = 2

func _ready() -> void:
    # Create a dash cooldown timer.
    $DashCooldown.wait_time = DASH_COOLDOWN
    $DashCooldown.one_shot = true

    # Begin in fall state
    current_state_enum = State.FALL
    current_state = STATES[current_state_enum]
    _change_state(current_state_enum)

    # Initialize current room
    curr_room = get_parent().get_node('Rooms/FactoryEntrance')
    prev_room = curr_room
    get_camera().fit_camera_limits_to_room(curr_room)

    # Save the current positions of all "y-axis mirrored" nodes so that they can
    # all be mirrored at once when the player changes direction.
    for node in get_tree().get_nodes_in_group('mirror_y_axis'):
        _mirror_y_axis_node_original_positions[node] = node.get_position()

func _input(event: InputEvent) -> void:
    var new_state = current_state.handle_input(self, event)
    if new_state != State.NO_CHANGE:
        _change_state(new_state)

func _physics_process(delta: float) -> void:
    var new_state = current_state.update(self, delta)
    if new_state != State.NO_CHANGE:
        _change_state(new_state)

# Change from one state in the state machine to another.
func _change_state(new_state_enum: int) -> void:
    var previous_state_enum := current_state_enum

    current_state.exit(self)
    current_state_enum = new_state_enum
    current_state = STATES[new_state_enum]
    current_state.enter(self, previous_state_enum)

    emit_signal('player_state_changed', current_state.get_name())

func move(new_velocity: Vector2) -> void:
    self.velocity = .move_and_slide(new_velocity, Globals.FLOOR_NORMAL)

func is_on_ground() -> bool:
    return .is_on_floor()

func is_in_air() -> bool:
    return not is_on_ground()

# Detects whether the player is currently colliding with the way (i.e. whether
# the player is actively pressing up against it). This is useful for initiating
# a wall slide so that e.g. the player can jump near walls if they're not
# pressed up against them.
func is_on_wall() -> bool:
    return .is_on_wall()

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

func get_sfx() -> Node2D:
    return $SFX as Node2D

func get_player_direction() -> int:
    return -1 if $Sprite.flip_h else 1

func set_player_direction(direction: int) -> void:
    # Flip player sprite.
    $Sprite.flip_h = (direction == -1)

    # Flip attack sprite.
    $AttackHitbox/Sprite.flip_h = (direction == -1)

    # Flip all "y-axis mirrored" nodes.
    if direction in [-1, 1]:
        for node in get_tree().get_nodes_in_group('mirror_y_axis'):
            var original_position = _mirror_y_axis_node_original_positions[node]
            node.position.x = original_position.x * direction

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

# Functions providing a more readable and convenient interface for managing
# dashes.
func can_dash() -> bool:
    return _can_dash
func consume_dash() -> void:
    _can_dash = false
func reset_dash() -> void:
    _can_dash = true

func can_jump() -> bool:
    return _jumps_remaining > 0
func consume_jump() -> void:
    _jumps_remaining -= 1
func reset_jump() -> void:
    _jumps_remaining = 2
