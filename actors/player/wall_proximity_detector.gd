extends Node2D

export(float) var CAST_DISTANCE = 7.0

onready var _top_front: RayCast2D = $TopFront
onready var _bot_front: RayCast2D = $BottomFront

onready var _top_back: RayCast2D = $TopBack
onready var _bot_back: RayCast2D = $BottomBack

var _direction: int = 1

func _ready() -> void:
    _top_front.set_cast_to(Vector2(CAST_DISTANCE, 0))
    _bot_front.set_cast_to(Vector2(CAST_DISTANCE, 0))

    _top_back.set_cast_to(Vector2(-CAST_DISTANCE, 0))
    _bot_back.set_cast_to(Vector2(-CAST_DISTANCE, 0))

func set_direction(new_direction: int) -> void:
    assert(new_direction in [-1, 1])

    _direction = new_direction

    # Flip both sets of raycasts.
    var new_cast_to_point = _direction * CAST_DISTANCE
    _top_front.cast_to.x = new_cast_to_point
    _bot_front.cast_to.x = new_cast_to_point
    _top_back.cast_to.x = -new_cast_to_point
    _bot_back.cast_to.x = -new_cast_to_point

func is_near_wall_front() -> bool:
    return _top_front.is_colliding() and _bot_front.is_colliding()
func is_near_wall_back() -> bool:
    return _top_back.is_colliding() and _bot_back.is_colliding()

func get_wall_normal_front():
    var top_front_wall_normal := _top_front.get_collision_normal()
    if top_front_wall_normal != Vector2.ZERO:
        return top_front_wall_normal
    return _bot_front.get_collision_normal()
func get_wall_normal_back():
    var top_back_wall_normal := _top_back.get_collision_normal()
    if top_back_wall_normal != Vector2.ZERO:
        return top_back_wall_normal
    return _bot_back.get_collision_normal()
