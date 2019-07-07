extends Node2D

export(float) var CAST_DISTANCE = 7.0

onready var _top: RayCast2D = $Top
onready var _bot: RayCast2D = $Bottom

var _direction: int = 1

func _ready() -> void:
    _top.set_cast_to(Vector2(CAST_DISTANCE, 0))
    _bot.set_cast_to(Vector2(CAST_DISTANCE, 0))

func set_direction(new_direction: int) -> void:
    assert new_direction in [-1, 1]

    _direction = new_direction

    # Since the rays are centered on the x-axis on the player, rotating them is
    # sufficient to reflect them on the y-axis.
    var rotation := deg2rad(0 if _direction == 1 else 180)
    _top.set_rotation(rotation)
    _bot.set_rotation(rotation)

func is_near_wall() -> bool:
    return _top.is_colliding() and _bot.is_colliding()