extends Node2D
class_name FireColumn

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func fire() -> void:
    _animation_player.play('fire_column')

func pause() -> void:
    _animation_player.stop()

func resume() -> void:
    fire()
