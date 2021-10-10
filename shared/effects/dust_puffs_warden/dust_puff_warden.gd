extends Node2D

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func start_and_queue_free() -> void:
    _animation_player.play('dust_puff_warden')
    yield(_animation_player, 'animation_finished')
    queue_free()
