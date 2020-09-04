extends Node2D
class_name DashManager

# The amount of time to wait after completing a dash before dashing again.
const DASH_COOLDOWN: float = 0.30

var _can_dash := true

onready var _dash_buffer_raycast: RayCast2D = $DashBufferRaycast
onready var _dash_cooldown_timer: Timer = $DashCooldown

func _ready() -> void:
    _dash_cooldown_timer.wait_time = DASH_COOLDOWN
    _dash_cooldown_timer.one_shot = true

func can_dash() -> bool:
    return _can_dash and get_dash_cooldown_timer().is_stopped()

func consume_dash() -> void:
    _can_dash = false

func reset_dash() -> void:
    _can_dash = true

func get_dash_buffer_raycast() -> RayCast2D:
    return _dash_buffer_raycast

func get_dash_cooldown_timer() -> Timer:
    return _dash_cooldown_timer
