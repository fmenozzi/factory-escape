extends Node2D
class_name DashBuffer

onready var _dash_buffer_raycast: RayCast2D = $DashBufferRaycast

func can_buffer_dash() -> bool:
    _dash_buffer_raycast.force_raycast_update()
    return _dash_buffer_raycast.is_colliding()
