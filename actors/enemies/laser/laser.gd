extends Node2D

export(float) var hitbox_width := 16.0

onready var _beam_sprite: Sprite = $Beam
onready var _raycast: RayCast2D = $Offset/RayCast2D
onready var _target: Position2D = $Target
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func shoot() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact.
    var collision_point_local := _get_collision_point_local()

    # Rotate and extend beam sprite to point to the collision point.
    _beam_sprite.rotation = collision_point_local.angle()
    _beam_sprite.region_rect.end.x = collision_point_local.length()

    # Set hitbox collision shape dynamically based on the laser's contact point
    # and the desired width of the hitbox.
    _hitbox_collision_shape.shape = _make_collision_shape(collision_point_local)
    _hitbox_collision_shape.rotation = collision_point_local.angle()
    _hitbox_collision_shape.position = collision_point_local / 2.0

func _get_collision_point_local() -> Vector2:
    _raycast.cast_to = _target.position
    _raycast.force_raycast_update()
    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to

func _make_collision_shape(collision_point: Vector2) -> RectangleShape2D:
    var shape := RectangleShape2D.new()
    shape.extents = Vector2(collision_point.length() / 2.0, hitbox_width / 2.0)
    return shape
