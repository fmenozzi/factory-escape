extends Node2D
class_name JumpBuffer

onready var _jump_buffer_raycast: RayCast2D = $JumpBufferRaycast

func can_buffer_jump() -> bool:
    _jump_buffer_raycast.force_raycast_update()
    return _jump_buffer_raycast.is_colliding()
