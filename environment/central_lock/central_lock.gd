extends Node2D
class_name CentralLock

onready var _upper_left: Sprite = $LightSprites/UpperLeft
onready var _upper_right: Sprite = $LightSprites/UpperRight
onready var _lower_left: Sprite = $LightSprites/LowerLeft
onready var _lower_right: Sprite = $LightSprites/LowerRight
onready var _central: Sprite = $LightSprites/Central

func _ready() -> void:
    _upper_left.modulate.a = 0
    _upper_right.modulate.a = 0
    _lower_left.modulate.a = 0
    _lower_right.modulate.a = 0
    _central.modulate.a = 0
