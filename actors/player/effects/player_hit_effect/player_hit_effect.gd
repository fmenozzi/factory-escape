extends Node2D
class_name PlayerHitEffect

signal hit_effect_finished

onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    _sprite.visible = false

func set_texture(texture: Texture) -> void:
    _sprite.texture = texture

func play_hit_effect() -> void:
    _sprite.visible = true
    _animation_player.play('hit_effect')
    yield(_animation_player, 'animation_finished')
    _sprite.visible = false
    emit_signal('hit_effect_finished')
