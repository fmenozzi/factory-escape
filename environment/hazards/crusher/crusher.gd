extends Node2D

onready var _head: KinematicBody2D = $CrusherHead
onready var _head_sprite: Sprite = $CrusherHead/Sprite
onready var _tween: Tween = $MoveTween

func _ready() -> void:
    var head_sprite_height := _head_sprite.texture.get_height()

    var crushed_position = _head.position
    var retracted_position = crushed_position + Vector2(0, -head_sprite_height)

    var delay := 1.0

    var crush_duration := 0.5
    var retract_duration := 2.0

    _tween.remove_all()
    _tween.interpolate_property(
        _head, 'position', crushed_position, retracted_position, retract_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
    _tween.interpolate_property(
        _head, 'position', retracted_position, crushed_position, crush_duration,
        Tween.TRANS_LINEAR, Tween.EASE_IN, delay + retract_duration)
    _tween.start()
