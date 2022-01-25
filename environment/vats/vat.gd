extends Node2D

export(Texture) var texture: Texture = null

onready var _bubbles: Particles2D = $Bubbles
onready var _sprite: Sprite = $VatSprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    if texture != null:
        _sprite.texture = texture
        _animation_player.play('suspend')

func pause() -> void:
    pass

func resume() -> void:
    pass

func show_visuals() -> void:
    _bubbles.speed_scale = 1.0

func hide_visuals() -> void:
    _bubbles.speed_scale = 0.0
