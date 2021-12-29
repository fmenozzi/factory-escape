extends Node2D

export(Switch.State) var switch_state: int = Switch.State.UNPRESSED

const SPEED := 2.0 * Util.TILE_SIZE

onready var _platform: KinematicBody2D = $Platform
onready var _switch: Switch = $Platform/Switch
onready var _destination: Position2D = $Destination
onready var _tween: Tween = $MoveTween

# The point that the elevator will follow (with an easing function). This is
# what we will manipulate with the move tween, rather than the elevator's
# position directly.
var _follow_point: Vector2 = Vector2.ZERO

# The time in seconds it takes the elevator to move from its origin to its
# destination (or vice versa).
var _move_duration: float

func _ready() -> void:
    _move_duration = _destination.position.length() / SPEED

    _switch.reset_state_to(switch_state)
    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

    set_physics_process(false)

func _physics_process(delta: float) -> void:
    # Rather than interpolate the platform's position directly, which can cause
    # inconsistent motion with platforms with different move distances, we ease
    # the platform's position to the follow point and manipulate the follow
    # point with the move tween.
    _platform.position = _platform.position.linear_interpolate(
        _follow_point, 0.1)

func lamp_reset() -> void:
    _platform.position = Vector2.ZERO
    _switch.reset_state_to(switch_state)
    set_physics_process(false)

func _on_switch_pressed() -> void:
    set_physics_process(true)

    _tween.remove_all()
    _tween.interpolate_property(
        self, '_follow_point', Vector2.ZERO, _destination.position, _move_duration)
    _tween.start()
