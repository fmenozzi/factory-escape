extends Node2D

onready var _steam: Particles2D = $Steam

func pause() -> void:
    pass

func resume() -> void:
    pass

func show_visuals() -> void:
    _steam.speed_scale = 1.0

func hide_visuals() -> void:
    _steam.speed_scale = 0.0
