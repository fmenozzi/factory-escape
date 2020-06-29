extends Node
class_name PushbackManager

export(float) var pushback_distance_tiles := 0.0
export(float) var pushback_duration := 0.0

onready var _pushback_duration_timer: Timer = $PushbackDurationTimer

var _pushback_direction := Vector2.ZERO
var _pushback_speed := 0.0

func _ready() -> void:
    _pushback_duration_timer.one_shot = true
    _pushback_duration_timer.wait_time = pushback_duration

    _pushback_speed = pushback_distance_tiles * Util.TILE_SIZE / pushback_duration

func start_pushback(direction: Vector2) -> void:
    _pushback_direction = direction
    _pushback_duration_timer.start()

func is_being_pushed_back() -> bool:
    return not _pushback_duration_timer.is_stopped()

func get_pushback_velocity() -> Vector2:
    return _pushback_speed * _pushback_direction
