extends Node2D

# The amount of time in seconds that the platform will idle before moving again.
export(float) var IDLE_DURATION := 1.0

# The speed in pixels per second at which the platform travels.
export(float) var SPEED := 2.0 * Util.TILE_SIZE

# The point that the moving platform will follow (with an easing function). This
# is what we will manipulate with the move tween, rather than the platform's
# position directly.
var _follow_point: Vector2 = Vector2.ZERO

onready var _platform: KinematicBody2D = $Platform
onready var _destination: Position2D = $Destination
onready var _tween: Tween = $MoveTween

func _ready() -> void:
    var move_duration := _destination.position.length() / SPEED

    # Idle and then move the platform to the MOVE_TO point.
    _tween.interpolate_property(
        self, "_follow_point", Vector2.ZERO, _destination.position,
        move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN, IDLE_DURATION)

    # Idle and then move the platform back to the starting point.
    _tween.interpolate_property(
        self, "_follow_point", _destination.position, Vector2.ZERO,
        move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN,
        move_duration + (2 * IDLE_DURATION))

    _tween.start()

func _physics_process(delta: float) -> void:
    # Rather than interpolate the platform's position directly, which can cause
    # inconsistent motion with platforms with different move distances, we ease
    # the platform's position to the follow point and manipulate the follow
    # point with the move tween.
    _platform.position = _platform.position.linear_interpolate(
        _follow_point, 0.1)

# Stop/start moving platforms. Useful for screen transitions.
func pause() -> void:
    set_physics_process(false)
    _tween.stop_all()
func resume() -> void:
    set_physics_process(true)
    _tween.resume_all()

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass
