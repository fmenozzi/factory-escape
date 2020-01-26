extends Node2D

enum Location {
    START,
    MOVING,
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
onready var _pressure_plate: Node2D = $Platform/PressurePlate
onready var _summon_to_start_lever: Node2D = $SummonToStartLever
onready var _summon_to_end_lever: Node2D = $SummonToEndLever
onready var _tween: Tween = $MoveTween

func _ready() -> void:
    _pressure_plate.connect('pressed', self, '_on_player_pressed_plate')

    _summon_to_start_lever.connect(
        'direction_changed_to', self, '_on_start_lever_activated')
    _summon_to_end_lever.connect(
        'direction_changed_to', self, '_on_end_lever_activated')

func _physics_process(delta: float) -> void:
    # Rather than interpolate the platform's position directly, which can cause
    # inconsistent motion with platforms with different move distances, we ease
    # the platform's position to the follow point and manipulate the follow
    # point with the move tween.
    _platform.position = _platform.position.linear_interpolate(
        _follow_point, 0.1)

func move_to_end() -> void:
    _location = Location.MOVING

    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', Vector2.ZERO, MOVE_TO, _move_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()

    yield(_tween, 'tween_completed')
    yield(get_tree().create_timer(1.0), 'timeout')
    _location = Location.END

func move_back_to_start() -> void:
    _location = Location.MOVING

    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', MOVE_TO, Vector2.ZERO, _move_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()

    yield(_tween, 'tween_completed')
    yield(get_tree().create_timer(1.0), 'timeout')
    _location = Location.START

func _on_player_pressed_plate() -> void:
    match _location:
        Location.START:
            move_to_end()

        Location.END:
            move_back_to_start()

func _on_start_lever_activated(new_direction: int) -> void:
    if _location == Location.END:
        move_back_to_start()

func _on_end_lever_activated(new_direction: int) -> void:
    if _location == Location.START:
        move_to_end()