extends Node2D

enum Location {
    START,
    MOVING,
    END,
}
var _location: int = Location.START

# The speed in pixels per second at which the platform travels.
export(float) var SPEED := 2.0 * Util.TILE_SIZE

# The point that the elevator will follow (with an easing function). This is
# what we will manipulate with the move tween, rather than the elevator's
# position directly.
var _follow_point: Vector2 = Vector2.ZERO

# The time in seconds it takes the elevator to move from its origin to its
# destination (or vice versa).
var _move_duration: float

onready var _platform: KinematicBody2D = $Platform
onready var _pressure_plate: Node2D = $Platform/PressurePlate
onready var _destination: Position2D = $Destination
onready var _summon_to_start_switch: Switch = $SummonToStartSwitch
onready var _summon_to_end_switch: Switch = $SummonToEndSwitch
onready var _tween: Tween = $MoveTween

func _ready() -> void:
    _move_duration = _destination.position.length() / SPEED

    _summon_to_start_switch.reset_state_to(Switch.State.PRESSED)
    _summon_to_end_switch.reset_state_to(Switch.State.UNPRESSED)

    _pressure_plate.connect('pressed', self, '_on_player_pressed_plate')

    _summon_to_start_switch.connect(
        'switch_press_finished', self, '_on_start_switch_pressed')
    _summon_to_end_switch.connect(
        'switch_press_finished', self, '_on_end_switch_pressed')

func _physics_process(delta: float) -> void:
    # Rather than interpolate the platform's position directly, which can cause
    # inconsistent motion with platforms with different move distances, we ease
    # the platform's position to the follow point and manipulate the follow
    # point with the move tween.
    _platform.position = _platform.position.linear_interpolate(
        _follow_point, 0.1)

func move_to_end() -> void:
    _summon_to_start_switch.reset_state_to(Switch.State.PRESSED)
    _summon_to_end_switch.reset_state_to(Switch.State.PRESSED)

    _location = Location.MOVING

    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', Vector2.ZERO, _destination.position,
        _move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()

    yield(_tween, 'tween_completed')
    yield(get_tree().create_timer(0.5), 'timeout')
    _location = Location.END

    _summon_to_start_switch.reset_state_to(Switch.State.UNPRESSED)

func move_back_to_start() -> void:
    _summon_to_start_switch.reset_state_to(Switch.State.PRESSED)
    _summon_to_end_switch.reset_state_to(Switch.State.PRESSED)

    _location = Location.MOVING

    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', _destination.position, Vector2.ZERO,
        _move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()

    yield(_tween, 'tween_completed')
    yield(get_tree().create_timer(0.5), 'timeout')
    _location = Location.START

    _summon_to_end_switch.reset_state_to(Switch.State.UNPRESSED)

func _on_player_pressed_plate() -> void:
    match _location:
        Location.START:
            move_to_end()

        Location.END:
            move_back_to_start()

func _on_start_switch_pressed() -> void:
    if _location == Location.END:
        move_back_to_start()

func _on_end_switch_pressed() -> void:
    if _location == Location.START:
        move_to_end()
