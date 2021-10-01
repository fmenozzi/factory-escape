extends Node2D
class_name LightningFloorIndicatorLights

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    _animation_player.play('reset_indicator_lights')

func get_animation_player() -> AnimationPlayer:
    return _animation_player
