extends Control

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    hide()

func show() -> void:
    _animation_player.play('spin')
    self.visible = true

func hide() -> void:
    _animation_player.stop(true)
    self.visible = false
