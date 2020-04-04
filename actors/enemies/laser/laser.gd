tool
extends Node2D

export(float, 0, 16) var outer_beam_width := 8.0 setget set_outer_beam_width
export(float, 0, 16) var inner_beam_width := 4.0 setget set_inner_beam_width

onready var _beam_sprite: Sprite = $Beam
onready var _raycast: RayCast2D = $Offset/RayCast2D
onready var _target: Position2D = $Target
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
    # Make sure each instance gets its own shader material.
    _beam_sprite.set_material(_beam_sprite.get_material().duplicate(true))

func shoot() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact.
    var collision_point_local := _get_collision_point_local()

    # Rotate and extend beam sprite to point to the collision point.
    _update_beam_sprite(collision_point_local)

    # Set hitbox collision shape dynamically based on the laser's contact point
    # and the desired width of the hitbox.
    _update_collision_shape(collision_point_local)

func set_outer_beam_width(new_outer_beam_width: float) -> void:
    # Hack to get around the fact that we need the beam sprite to be loaded in
    # the tree before we can access it below.
    if not is_inside_tree():
        yield(self, 'ready')

    outer_beam_width = new_outer_beam_width

    # Convert outer beam width from pixels into UV-space for the beam shader.
    var width_uv := outer_beam_width / _beam_sprite.texture.get_height()
    _beam_sprite.get_material().set_shader_param(
        'outer_beam_half_width_uv', width_uv / 2.0)

    # Update collision shape to use new width, since the outer beam is what
    # determines the laser's hitbox.
    _update_collision_shape(_get_collision_point_local())

func set_inner_beam_width(new_inner_beam_width: float) -> void:
    # Hack to get around the fact that we need the beam sprite to be loaded in
    # the tree before we can access it below.
    if not is_inside_tree():
        yield(self, 'ready')

    inner_beam_width = new_inner_beam_width

    # Convert inner beam width from pixels into UV-space for the beam shader.
    var width_uv := inner_beam_width / _beam_sprite.texture.get_height()
    _beam_sprite.get_material().set_shader_param(
        'inner_beam_half_width_uv', width_uv / 2.0)

func _get_collision_point_local() -> Vector2:
    _raycast.cast_to = _target.position
    _raycast.force_raycast_update()
    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to

func _update_beam_sprite(collision_point_local: Vector2) -> void:
    _beam_sprite.rotation = collision_point_local.angle()
    _beam_sprite.region_rect.end.x = collision_point_local.length()

func _update_collision_shape(collision_point_local: Vector2) -> void:
    _hitbox_collision_shape.shape = _make_collision_shape(collision_point_local)
    _hitbox_collision_shape.rotation = collision_point_local.angle()
    _hitbox_collision_shape.position = collision_point_local / 2.0

func _make_collision_shape(collision_point: Vector2) -> RectangleShape2D:
    var shape := RectangleShape2D.new()
    shape.extents = Vector2(
        collision_point.length() / 2.0, outer_beam_width / 2.0)
    return shape
