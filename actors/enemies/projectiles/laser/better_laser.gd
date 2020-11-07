extends Node2D

# The maximum length of the laser beam.
const MAX_LENGTH: float = 100.0 * Util.TILE_SIZE

onready var _raycast: RayCast2D = $RayCast2D
onready var _line: Line2D = $Line2D

func _ready() -> void:
    _raycast.cast_to = Vector2(0, MAX_LENGTH)

    _line.add_point(Vector2.ZERO)
    _line.add_point(_raycast.cast_to)

    set_physics_process(false)

func _physics_process(delta: float) -> void:
    _cast_laser_beam()

func start() -> void:
    set_physics_process(true)

func stop() -> void:
    set_physics_process(false)

func _cast_laser_beam() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact
    var collision_point_local = _get_collision_point_local()

    # Update the end of the line representing the beam.
    _line.points[1] = collision_point_local

func _get_collision_point_local() -> Vector2:
    _raycast.force_raycast_update()

    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to
