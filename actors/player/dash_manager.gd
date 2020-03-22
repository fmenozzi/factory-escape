extends Node2D
class_name DashManager

var _can_dash := true

onready var _dash_buffer_raycast: RayCast2D = $DashBufferRaycast

func can_dash() -> bool:
    return _can_dash

func consume_dash() -> void:
    _can_dash = false

func reset_dash() -> void:
    _can_dash = true

func get_dash_buffer_raycast() -> RayCast2D:
    return _dash_buffer_raycast
