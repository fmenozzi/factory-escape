extends Node2D
class_name JumpBuffer

onready var _jump_buffer_area: Area2D = $JumpBufferArea

func can_buffer_jump() -> bool:
    return not _jump_buffer_area.get_overlapping_bodies().empty()
