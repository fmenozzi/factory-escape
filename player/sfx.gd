extends Node2D

onready var _wall_slide_trail: Particles2D = $WallSlideTrail

func start_wall_slide_trail() -> void:
    _wall_slide_trail.emitting = true
func stop_wall_slide_trail() -> void:
    _wall_slide_trail.emitting = false