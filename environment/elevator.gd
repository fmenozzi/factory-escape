extends Node2D

enum Location {
    START,
    END,
}
var _location: int = Location.START

# The local offset defining where the elevator will move to.
export(Vector2) var MOVE_TO := 8 * Util.TILE_SIZE * Vector2.UP

# The speed in pixels per second at which the platform travels.
export(float) var SPEED := 2.0 * Util.TILE_SIZE

# The point that the elevator will follow (with an easing function). This is
# what we will manipulate with the move tween, rather than the elevator's
# position directly.
var _follow_point: Vector2 = Vector2.ZERO

# The time in seconds it takes the elevator to move from its origin to its
# destination (or vice versa).
var _move_duration: float = MOVE_TO.length() / SPEED

onready var _platform: KinematicBody2D = $Platform
onready var _tween: Tween = $MoveTween

func _ready() -> void:
    move_to_end()

func _physics_process(delta: float) -> void:
    # Rather than interpolate the platform's position directly, which can cause
    # inconsistent motion with platforms with different move distances, we ease
    # the platform's position to the follow point and manipulate the follow
    # point with the move tween.
    _platform.position = _platform.position.linear_interpolate(
        _follow_point, 0.1)

func move_to_end() -> void:
    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', Vector2.ZERO, MOVE_TO, _move_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()

func move_back_to_start() -> void:
    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', MOVE_TO, Vector2.ZERO, _move_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()