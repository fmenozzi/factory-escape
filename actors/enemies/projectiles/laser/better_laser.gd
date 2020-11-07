extends Node2D

# The maximum length of the laser beam.
const MAX_LENGTH: float = 100.0 * Util.TILE_SIZE

var _is_shooting := false
var _original_width := 0.0

onready var _raycast: RayCast2D = $RayCast2D
onready var _line: Line2D = $Line2D
onready var _tween: Tween = $WidthTween

func _ready() -> void:
    _raycast.cast_to = Vector2(MAX_LENGTH, 0)

    _line.add_point(Vector2.ZERO)
    _line.add_point(_raycast.cast_to)

    _original_width = _line.width

    set_physics_process(false)
    hide()

func _physics_process(delta: float) -> void:
    _cast_laser_beam()

func shoot() -> void:
    if _is_shooting:
        return

    _is_shooting = true

    # Activate laser.
    show()
    set_physics_process(true)

    # Startup animation.
    _animate_beam_width(0, _original_width)
    yield(_tween, 'tween_all_completed')

    # Shot duration.
    yield(get_tree().create_timer(2.0), 'timeout')

    # Wind down animation.
    _animate_beam_width(_original_width, 0)
    yield(_tween, 'tween_all_completed')

    # Deactivate laser.
    set_physics_process(false)
    hide()

    _is_shooting = false

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

func _animate_beam_width(old: float, new: float) -> void:
    var duration := 0.5

    _tween.stop_all()
    _tween.interpolate_property(_line, 'width', old, new, duration)
    _tween.start()
