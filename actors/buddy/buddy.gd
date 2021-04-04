extends KinematicBody2D
class_name Buddy

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    _animation_player.play('idle')
