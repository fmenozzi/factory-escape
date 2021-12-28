extends Control

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func start() -> void:
    _animation_player.play('start')

func stop() -> void:
    _animation_player.play('stop')
