extends Node2D
class_name CentralLock

enum LockLight {
    UPPER_LEFT,
    UPPER_RIGHT,
    LOWER_LEFT,
    LOWER_RIGHT,
    CENTRAL,
}

onready var _upper_left: Sprite = $LightSprites/UpperLeft
onready var _upper_right: Sprite = $LightSprites/UpperRight
onready var _lower_left: Sprite = $LightSprites/LowerLeft
onready var _lower_right: Sprite = $LightSprites/LowerRight
onready var _central: Sprite = $LightSprites/Central
onready var _tween: Tween = $Tween

func _ready() -> void:
    _upper_left.modulate.a = 0
    _upper_right.modulate.a = 0
    _lower_left.modulate.a = 0
    _lower_right.modulate.a = 0
    _central.modulate.a = 0

func turn_on_light(light: int) -> void:
    assert(light in [
        LockLight.UPPER_LEFT,
        LockLight.UPPER_RIGHT,
        LockLight.LOWER_LEFT,
        LockLight.LOWER_RIGHT,
        LockLight.CENTRAL,
    ])

    match light:
        LockLight.UPPER_LEFT:
            _turn_light_on(_upper_left)

        LockLight.UPPER_RIGHT:
            _turn_light_on(_upper_right)

        LockLight.LOWER_LEFT:
            _turn_light_on(_lower_left)

        LockLight.LOWER_RIGHT:
            _turn_light_on(_lower_right)

        LockLight.CENTRAL:
            _turn_light_on(_central)

func _turn_light_on(sprite: Sprite) -> void:
    _tween.interpolate_property(
        sprite, 'modulate', Color(1, 1, 1, 0), Color(1.2, 1.2, 1.2), 2)
    _tween.start()
