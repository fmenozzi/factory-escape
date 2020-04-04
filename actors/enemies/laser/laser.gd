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
onready var _tween: Tween = $WobbleTween

var _is_shooting := false

# Temp variables used to save the
var _outer_beam_width := 0.0
var _inner_beam_width := 0.0

func _ready() -> void:
    # Make sure each instance gets its own shader material.
    _beam_sprite.set_material(_beam_sprite.get_material().duplicate(true))

    _tween.connect('tween_step', self, '_on_wobble_tween_step')

func shoot() -> void:
    if _is_shooting:
        return

    _is_shooting = true

    # Get the local coordinates of the point where the laser actually makes
    # contact.
    var collision_point_local = _get_collision_point_local()

    _update_beam_sprite(collision_point_local)
    _update_shader_params()
    _update_collision_shape(collision_point_local)

    # Start the telegraph for the laser shot.
    _hitbox_collision_shape.set_deferred('disabled', true)
    _start_laser_telegraph()

    # Wait for telegraph to finish before firing the actual shot.
    yield(self, 'telegraph_finished')
    _hitbox_collision_shape.set_deferred('disabled', false)
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
    # Make the collision shape slightly narrower than the width of the outer
    # beam.
    var shape := RectangleShape2D.new()
    shape.extents = Vector2(
        collision_point.length() / 2.0, (outer_beam_width / 2.0) - 1)
    return shape

func _update_beam_sprite(collision_point_local: Vector2) -> void:
    # Rotate and extend beam sprite to point to collision point.
    _beam_sprite.rotation = collision_point_local.angle()
    _beam_sprite.region_rect.end.x = collision_point_local.length()

func _update_shader_params() -> void:
    # Update beam rendering by setting shader params.
    var beam_width_px := _beam_sprite.texture.get_height()

    var outer_beam_width_uv := outer_beam_width / beam_width_px
    var inner_beam_width_uv := inner_beam_width / beam_width_px

    var shader_material: ShaderMaterial = _beam_sprite.get_material()
    shader_material.set_shader_param(
        'outer_beam_half_width_uv', outer_beam_width_uv / 2.0)
    shader_material.set_shader_param(
        'inner_beam_half_width_uv', inner_beam_width_uv / 2.0)

func _update_collision_shape(collision_point_local: Vector2) -> void:
    # Set hitbox collision shape dynamically based on the laser's contact point
    # and the desired width of the hitbox.
    _hitbox_collision_shape.shape = _make_collision_shape(collision_point_local)
    _hitbox_collision_shape.rotation = collision_point_local.angle()
    _hitbox_collision_shape.position = collision_point_local / 2.0

func _start_laser_telegraph() -> void:
    _outer_beam_width = outer_beam_width
    _inner_beam_width = inner_beam_width

    # No inner beam during telegraph.
    inner_beam_width = 0.0

    # Small outer beam during telegraph.
    outer_beam_width = 1.5

    # "Wobble" the outer beam width.
    var num_wobbles := 6
    _start_telegraph_wobble(num_wobbles)

    yield(_tween, 'tween_all_completed')
    emit_signal('telegraph_finished')

func _start_laser_shot() -> void:
    # Reset beam widths.
    outer_beam_width = _outer_beam_width
    inner_beam_width = _inner_beam_width

    var num_wobbles := 8
    _start_shooting_wobble(num_wobbles)

    yield(_tween, 'tween_all_completed')
    emit_signal('shot_finished')

func _start_telegraph_wobble(num_wobbles: int) -> void:
    _tween.remove_all()
    for i in range(num_wobbles):
        # Wobble outer beam.
        _tween.interpolate_property(
            self, 'outer_beam_width', outer_beam_width, outer_beam_width - 1,
            TELEGRAPH_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, i * (TELEGRAPH_DURATION / float(num_wobbles)))
        _tween.interpolate_property(
            self, 'outer_beam_width', outer_beam_width - 1, outer_beam_width,
            TELEGRAPH_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, (i+1) * (TELEGRAPH_DURATION / float(num_wobbles)))
    _tween.start()

func _start_shooting_wobble(num_wobbles: int) -> void:
    _tween.remove_all()
    for i in range(num_wobbles):
        # Wobble outer beam.
        _tween.interpolate_property(
            self, 'outer_beam_width', outer_beam_width, outer_beam_width - 1,
            SHOT_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, i * (SHOT_DURATION / float(num_wobbles)))
        _tween.interpolate_property(
            self, 'outer_beam_width', outer_beam_width - 1, outer_beam_width,
            SHOT_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, (i+1) * (SHOT_DURATION / float(num_wobbles)))

        # Wobble inner beam.
        _tween.interpolate_property(
            self, 'inner_beam_width', inner_beam_width, inner_beam_width - 1,
            SHOT_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, i * (SHOT_DURATION / float(num_wobbles)))
        _tween.interpolate_property(
            self, 'inner_beam_width', inner_beam_width - 1, inner_beam_width,
            SHOT_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, (i+1) * (SHOT_DURATION / float(num_wobbles)))
    _tween.start()

func _on_wobble_tween_step(_obj, _key, _elapsed, _val) -> void:
    # Ensure that we're updating the shader params on each tween step. Note that
    # we DON'T update the collision shape because this causes collisions not to
    # occur.
    _update_shader_params()
