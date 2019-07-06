extends Node2D

onready var _top: RayCast2D = $Top
onready var _bot: RayCast2D = $Bottom

# Defaults to facing right.
var _direction: int = 1

func _ready() -> void:
    _top.set_enabled(true)
    _bot.set_enabled(true)

func set_direction(new_direction: int) -> void:
    assert new_direction in [-1, 1]

    _direction = new_direction

    # Since the rays are centered on the x-axis on the player, rotating them is
    # sufficient to reflect them on the y-axis.
    var rotation := deg2rad(-90 * _direction)
    _top.set_rotation(rotation)
    _bot.set_rotation(rotation)

func get_direction() -> int:
    return _direction

func is_on_wall() -> bool:
    return _top.is_colliding() and _bot.is_colliding()