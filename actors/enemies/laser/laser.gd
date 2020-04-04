extends Node2D

signal telegraph_finished
signal shot_finished

export(float, 0, 16) var outer_beam_width := 8.0
export(float, 0, 16) var inner_beam_width := 4.0

# The amount of time the laser spends telegraphing the subsequent shot, during
# which the player cannot be harmed.
const TELEGRAPH_DURATION: float = 1.0

# The amount of time the laser spends shooting, during which it remains active
# and can harm the player.
const SHOT_DURATION: float = 1.0

onready var _beam_sprite: Sprite = $Beam
onready var _raycast: RayCast2D = $Offset/RayCast2D
onready var _target: Position2D = $Target
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

var _is_shooting := false

# Temp variables used to save the
var _outer_beam_width := 0.0
var _inner_beam_width := 0.0

func _ready() -> void:
    # Make sure each instance gets its own shader material.
    _beam_sprite.set_material(_beam_sprite.get_material().duplicate(true))

func shoot() -> void:
    if _is_shooting:
        return

    _is_shooting = true

    _update()

    # Start the telegraph for the laser shot.
    _start_laser_telegraph()

    # Wait for telegraph to finish before firing the actual shot.
    yield(self, 'telegraph_finished')
    _start_laser_shot()

    # Once the shot is finished, we're able to shoot again.
    yield(self, 'shot_finished')
    _is_shooting = false

func _get_collision_point_local() -> Vector2:
    _raycast.cast_to = _target.position
    _raycast.force_raycast_update()
    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to

func _make_collision_shape(collision_point: Vector2) -> RectangleShape2D:
    var shape := RectangleShape2D.new()
    shape.extents = Vector2(
        collision_point.length() / 2.0, outer_beam_width / 2.0)
    return shape

func _update() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact.
    var collision_point_local = _get_collision_point_local()

    # Rotate and extend beam sprite to point to collision point.
    _beam_sprite.rotation = collision_point_local.angle()
    _beam_sprite.region_rect.end.x = collision_point_local.length()

    # Update beam rendering by setting shader params.
    var beam_width_px := _beam_sprite.texture.get_height()

    var outer_beam_width_uv := outer_beam_width / beam_width_px
    var inner_beam_width_uv := inner_beam_width / beam_width_px

    var shader_material: ShaderMaterial = _beam_sprite.get_material()
    shader_material.set_shader_param(
        'outer_beam_half_width_uv', outer_beam_width_uv / 2.0)
    shader_material.set_shader_param(
        'inner_beam_half_width_uv', inner_beam_width_uv / 2.0)

    # Set hitbox collision shape dynamically based on the laser's contact point
    # and the desired width of the hitbox.
    _hitbox_collision_shape.shape = _make_collision_shape(collision_point_local)
    _hitbox_collision_shape.rotation = collision_point_local.angle()
    _hitbox_collision_shape.position = collision_point_local / 2.0

func _start_laser_telegraph() -> void:
    _outer_beam_width = outer_beam_width
    _inner_beam_width = inner_beam_width

    outer_beam_width = 1.0
    inner_beam_width = 0.0

    _update()

    yield(get_tree().create_timer(TELEGRAPH_DURATION), 'timeout')
    emit_signal('telegraph_finished')

func _start_laser_shot() -> void:
    outer_beam_width = _outer_beam_width
    inner_beam_width = _inner_beam_width

    _update()

    yield(get_tree().create_timer(SHOT_DURATION), 'timeout')
    emit_signal('shot_finished')
