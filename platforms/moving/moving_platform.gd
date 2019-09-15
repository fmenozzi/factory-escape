extends Node2D

# The amount of time in seconds that the platform will idle before moving again.
export(float) var IDLE_DURATION := 1.0

# The local offset defining where the platform will move.
export(Vector2) var MOVE_TO := 4 * Util.TILE_SIZE * Vector2.RIGHT

# The speed in pixels per second at which the platform travels.
export(float) var SPEED := 2.0 * Util.TILE_SIZE

# The point that the moving platform will follow (with an easing function). This
# is what we will manipulate with the move tween, rather than the platform's
# position directly.
var _follow_point: Vector2 = Vector2.ZERO

onready var _platform: KinematicBody2D = $Platform
onready var _tween: Tween = $MoveTween

func _ready() -> void:
    var move_duration := MOVE_TO.length() / SPEED

    # Idle and then move the platform to the MOVE_TO point.
    _tween.interpolate_property(
        self, "_follow_point", Vector2.ZERO, MOVE_TO, move_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN, IDLE_DURATION)

    # Idle and then move the platform back to the starting point.
    _tween.interpolate_property(
        self, "_follow_point", MOVE_TO, Vector2.ZERO, move_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN, move_duration + (2 * IDLE_DURATION))

    _tween.start()

func _physics_process(delta: float) -> void:
    # Rather than interpolate the platform's position directly, which can cause
    # inconsistent motion with platforms with different move distances, we ease
    # the platform's position to the follow point and manipulate the follow
    # point with the move tween.
    _platform.position = _platform.position.linear_interpolate(
        _follow_point, 0.1)