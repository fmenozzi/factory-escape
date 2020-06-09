extends Node2D
class_name Scanner

export(float) var max_length_tiles := 100.0
export(float) var width_px := 0.5

onready var _raycast: RayCast2D = $RayCast2D
onready var _line: Line2D = $Line2D

func _ready() -> void:
    _raycast.cast_to.x = max_length_tiles * Util.TILE_SIZE

    _line.width = width_px
    _line.add_point(Vector2.ZERO)
    _line.add_point(_raycast.cast_to)

func _physics_process(delta: float) -> void:
    _update_raycast()

func _update_raycast() -> void:
    _raycast.force_raycast_update()

    # Determine where the end point of the scanning line should be.
    var end_point_local := _raycast.cast_to
    if _raycast.is_colliding():
        end_point_local = _line.to_local(_raycast.get_collision_point())

    # Draw the scanning line.
    _line.set_point_position(1, end_point_local)

func is_colliding_with_player() -> bool:
    _raycast.force_raycast_update()
    return _raycast.get_collider() is Player
