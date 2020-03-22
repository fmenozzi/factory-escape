extends Node2D
class_name JumpManager

var _jumps_remaining := 2

onready var _jump_buffer_raycast: RayCast2D = $JumpBufferRaycast

func can_jump() -> bool:
    return _jumps_remaining > 0

func consume_jump() -> void:
    _jumps_remaining -= 1

func reset_jump() -> void:
    _jumps_remaining = 2

func get_jump_buffer_raycast() -> RayCast2D:
    return _jump_buffer_raycast
