extends Node2D
class_name Springboard

signal sprung

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _trigger: Area2D = $TriggerArea

func _ready() -> void:
    _trigger.connect('body_entered', self, '_on_player_entered')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _animation_player.play('spring')
