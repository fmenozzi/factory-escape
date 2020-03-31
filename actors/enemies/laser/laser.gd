extends Node2D

onready var _beam_sprite: Sprite = $Beam
onready var _raycast: RayCast2D = $Offset/RayCast2D
onready var _target: Position2D = $Target

func shoot() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact.
    var collision_point_local := _get_collision_point_local()

    # Rotate and extend beam sprite to point to the collision point.
    _beam_sprite.rotation = collision_point_local.angle()
    _beam_sprite.region_rect.end.x = collision_point_local.length()

func _get_collision_point_local() -> Vector2:
    _raycast.cast_to = _target.position
    _raycast.force_raycast_update()
    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to
