extends Node2D
class_name DashBuffer

onready var _dash_buffer_area: Area2D = $DashBufferArea

func can_buffer_dash() -> bool:
    return not _dash_buffer_area.get_overlapping_bodies().empty()
