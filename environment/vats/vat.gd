extends Node2D

export(Texture) var texture: Texture = null

onready var _sprite: Sprite = $VatSprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    if texture != null:
        _sprite.texture = texture
        _animation_player.play('suspend')
