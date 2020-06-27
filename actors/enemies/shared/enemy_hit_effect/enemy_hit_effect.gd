extends Node2D
class_name EnemyHitEffect

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    _animation_player.play('hit_effect')
    yield(_animation_player, 'animation_finished')
    queue_free()
