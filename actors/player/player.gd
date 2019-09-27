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
    GRAPPLE_START,
    GRAPPLE,
    STAGGER,
}

# Maps State enum to corresponding state scripts.
onready var STATES = {
    State.IDLE:          $States/Idle,
    State.WALK:          $States/Walk,
    State.JUMP:          $States/Jump,
    State.DOUBLE_JUMP:   $States/DoubleJump,
    State.FALL:          $States/Fall,
    State.DASH:          $States/Dash,
    State.WALL_SLIDE:    $States/WallSlide,
    State.WALL_JUMP:     $States/WallJump,
    State.GRAPPLE_START: $States/GrappleStart,
    State.GRAPPLE:       $States/Grapple,
    State.STAGGER:       $States/Stagger,
}

var current_state: Node = null
var current_state_enum: int = -1

# Vector denoting the 2D movement to be applied to the player during each
# update() call, measured in pixels per second.
var velocity: Vector2 = Vector2.ZERO

# The speed at which the player can move the character left and right, measured
# in pixels per second.
var MOVEMENT_SPEED: float = 6 * Util.TILE_SIZE

# The min/max jump heights the player can achieve in pixels. Releasing the jump
# button early will "cut" the jump somewhere between these two values, allowing
# for variable-height jumps.
var MAX_JUMP_HEIGHT: float = 3.50 * Util.TILE_SIZE
var MIN_JUMP_HEIGHT: float = 0.50 * Util.TILE_SIZE

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

onready var _wall_proximity_detector: Node2D = $WallProximityDetector

onready var _wall_slide_trail_effect: Particles2D = $WallSlideTrail

onready var _grapple_rope: Line2D = $GrappleRope
onready var _grapple_line_of_sight: RayCast2D = $GrappleLineOfSight

# The grapple point to be used the next time the player presses the grapple
# button. This is updated on every frame based on several candidacy rules. If
# there are no valid grapple points for the player on a given frame, this is set
# to null and grappling has no effect.
var _next_grapple_point: GrapplePoint = null

var _nearby_sign = null

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
    _change_state({'new_state': State.FALL})

    # Initialize current room
    curr_room = get_parent().get_node('Rooms/FactoryEntrance')
    prev_room = curr_room
    get_camera().fit_camera_limits_to_room(curr_room)

    # Save the current positions of all "y-axis mirrored" nodes so that they can
    # all be mirrored at once when the player changes direction.
    for node in get_tree().get_nodes_in_group('mirror_y_axis'):
        _mirror_y_axis_node_original_positions[node] = node.get_position()

    $Hurtbox.connect('area_entered', self, '_on_hit_taken')

func _unhandled_input(event: InputEvent) -> void:
    var new_state_dict = current_state.handle_input(self, event)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func _physics_process(delta: float) -> void:
    _update_next_grapple_point()

    var new_state_dict = current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

# Change from one state in the state machine to another.
func _change_state(new_state_dict: Dictionary) -> void:
    var new_state_enum: int = new_state_dict['new_state']
    var previous_state_enum := current_state_enum

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = previous_state_enum

    current_state.exit(self)
    current_state_enum = new_state_enum
    current_state = STATES[new_state_enum]
    current_state.enter(self, new_state_dict)

    emit_signal('player_state_changed', current_state.get_name())

func current_state() -> int:
    return current_state_enum

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    self.velocity = .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

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

# Detects whether the player is close to a wall without necessarily directly
# colliding with it. This is useful for making quick consecutive wall jumps feel
# more comfortable by not requiring the player to connect with the wall for a
# frame before continuing the wall jump chain.
func is_near_wall_front() -> bool:
    return _wall_proximity_detector.is_near_wall_front()
func is_near_wall_back() -> bool:
    return _wall_proximity_detector.is_near_wall_back()

# Gets the wall normal if either set of raycasts is colliding with the wall, or
# Vector2.ZERO otherwise. Useful for ensuring proper player direction when
# performing wall jumps.
func get_wall_normal_front() -> Vector2:
    return _wall_proximity_detector.get_wall_normal_front()
func get_wall_normal_back() -> Vector2:
    return _wall_proximity_detector.get_wall_normal_back()

func start_attack() -> void:
    $AnimationPlayer.play('attack')

# Flush animation queue and make attack sprite invisible so that we can cancel
# attack animations cleanly.
func stop_attack() -> void:
    $AnimationPlayer.clear_queue()
    $AttackHitbox/Sprite.set_visible(false)

func get_health() -> Node:
    return $Health as Node

func get_animation_player() -> AnimationPlayer:
    return $AnimationPlayer as AnimationPlayer

func get_camera() -> Camera2D:
    return $CameraAnchor/Camera2D as Camera2D

func get_dash_cooldown_timer() -> Timer:
    return $DashCooldown as Timer

func get_wall_slide_trail() -> Particles2D:
    return _wall_slide_trail_effect

func get_grapple_rope() -> Line2D:
    return _grapple_rope

func get_direction() -> int:
    return -1 if $Sprite.flip_h else 1

func set_direction(direction: int) -> void:
    # Flip player sprite.
    $Sprite.flip_h = (direction == -1)

    # Flip attack sprite.
    $AttackHitbox/Sprite.flip_h = (direction == -1)

    # Flip wall detector raycasts.
    if direction in [-1, 1]:
        _wall_proximity_detector.set_direction(direction)

    # Flip all "y-axis mirrored" nodes.
    if direction in [-1, 1]:
        for node in get_tree().get_nodes_in_group('mirror_y_axis'):
            var original_position = _mirror_y_axis_node_original_positions[node]
            node.position.x = original_position.x * direction

func set_nearby_sign(new_sign: Area2D) -> void:
    _nearby_sign = new_sign
func get_nearby_sign() -> Area2D:
    return _nearby_sign

# Pause/resume processing for player node specifically. Used during room
# transitions.
func pause() -> void:
    set_physics_process(false)
    set_process_unhandled_input(false)

    $AnimationPlayer.stop(false)

    $States/Dash/DashDuration.paused = true
    $States/Dash/DashEcho.paused = true
    $DashCooldown.paused = true
    $States/Stagger/StaggerDuration.paused = true
func unpause() -> void:
    set_physics_process(true)
    set_process_unhandled_input(true)

    $AnimationPlayer.play()

    $States/Dash/DashDuration.paused = false
    $States/Dash/DashEcho.paused = false
    $DashCooldown.paused = false
    $States/Stagger/StaggerDuration.paused = false

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

func get_next_grapple_point() -> GrapplePoint:
    return _next_grapple_point

func _update_next_grapple_point() -> void:
    _next_grapple_point = null

    # Determine candidate set of grapple points and reset grapple point colors.
    var candidate_grapple_points := []
    for grapple_point in curr_room.get_grapple_points():
        grapple_point.get_node('Sprite').modulate = Color.white
        if _can_grapple_to(grapple_point):
            candidate_grapple_points.append(grapple_point)

    # Sort candidate grapple points by distance to player.
    candidate_grapple_points.sort_custom(self, '_grapple_distance_comparator')

    # Pick the first grapple point that the player is facing. If the player is
    # facing away from all available grapple points, pick the closest one.
    if not candidate_grapple_points.empty():
        _next_grapple_point = candidate_grapple_points[0]
        for grapple_point in candidate_grapple_points:
            var grapple_point_direction := Util.direction(self, grapple_point)
            if self.get_direction() == grapple_point_direction:
                _next_grapple_point = grapple_point
                break

    # Color the next grapple point green.
    if _next_grapple_point:
        _next_grapple_point.get_node('Sprite').modulate = Color.green

func _grapple_point_in_line_of_sight(grapple_point: GrapplePoint) -> bool:
    _grapple_line_of_sight.set_cast_to(
        _grapple_line_of_sight.to_local(
            grapple_point.get_attachment_pos().global_position))
    _grapple_line_of_sight.force_raycast_update()
    return not _grapple_line_of_sight.is_colliding()

func _grapple_point_in_range(grapple_point: GrapplePoint) -> bool:
    return grapple_point.get_grapple_range_area().overlaps_body(self)

func _player_in_no_grapple_area(grapple_point: GrapplePoint) -> bool:
    return grapple_point.get_no_grapple_area().overlaps_body(self)

func _grapple_point_on_screen(grapple_point: GrapplePoint) -> bool:
    return grapple_point.is_on_screen()

func _can_grapple_to(grapple_point: GrapplePoint) -> bool:
    if not grapple_point.is_available():
        return false

    if not _grapple_point_in_line_of_sight(grapple_point):
        return false

    if not _grapple_point_in_range(grapple_point):
        return false

    if _player_in_no_grapple_area(grapple_point):
        return false

    if not _grapple_point_on_screen(grapple_point):
        return false

    return true

func _grapple_distance_comparator(a: GrapplePoint, b: GrapplePoint) -> bool:
    var distance_to_a := a.global_position.distance_to(self.global_position)
    var distance_to_b := b.global_position.distance_to(self.global_position)
    return distance_to_a < distance_to_b

func _on_hit_taken(hitbox: Area2D) -> void:
    # Take damage and stagger when hit.
    get_health().take_damage(1)
    _change_state({'new_state': State.STAGGER})
