extends Node2D
class_name Laser

signal shot_finished
signal shot_cancelled

# The maximum length of the laser beam.
const MAX_LENGTH: float = 100.0 * Util.TILE_SIZE

# The maximum width of the outer beam.
const MAX_WIDTH_OUTER: float = 4.0

# The maximum width of the inner beam.
const MAX_WIDTH_INNER: float = 2.0

# The maximum radius of the impact sprite in UV coordinates.
const MAX_IMPACT_SPRITE_RADIUS_UV: float = 0.35

# The color of the outer beam during the telegraph phase.
const TELEGRAPH_COLOR: Color = Color('ff4f78')

# The amount of time the laser spends telegraphing the subsequent shot, during
# which the player cannot be harmed.
const TELEGRAPH_DURATION: float = 1.0

# The color of the outer beam during the shoot phase.
const SHOT_COLOR: Color = Color(
    TELEGRAPH_COLOR.r * 1.3,
    TELEGRAPH_COLOR.g * 1.3,
    TELEGRAPH_COLOR.b * 1.3,
    TELEGRAPH_COLOR.a
)

# The amount of time the laser spends shooting, during which it remains active
# and can harm the player.
const SHOT_DURATION: float = 1.0

# The amount of time the laser spends winding up to its full width or down to
# zero width during startup/wind down.
const WIND_DOWN_DURATION: float = 0.25

enum State {
    INACTIVE,
    TELEGRAPH,
    SHOOT,
    CANCELLED,
}

var _current_state: int = State.INACTIVE

onready var _raycast: RayCast2D = $RayCast2D
onready var _outer_beam: Line2D = $OuterBeam
onready var _inner_beam: Line2D = $InnerBeam
onready var _tween: Tween = $WidthTween
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _beam_end: Position2D = $BeamEnd
onready var _impact_sprite: Sprite = $BeamEnd/BeamImpact
onready var _impact_sprite_mat: ShaderMaterial = _impact_sprite.get_material()
onready var _impact_sparks: Particles2D = $BeamEnd/ImpactSparks

func _ready() -> void:
    _raycast.cast_to = Vector2(MAX_LENGTH, 0)

    _outer_beam.width = MAX_WIDTH_OUTER
    _outer_beam.add_point(Vector2.ZERO)
    _outer_beam.add_point(_raycast.cast_to)

    _inner_beam.width = MAX_WIDTH_INNER
    _inner_beam.add_point(Vector2.ZERO)
    _inner_beam.add_point(_raycast.cast_to)

    _hitbox_collision_shape.shape = RectangleShape2D.new()
    _hitbox_collision_shape.shape.extents = Vector2.ZERO

    _beam_end.position.x = MAX_LENGTH
    _beam_end.hide()

    set_physics_process(false)
    hide()

func _physics_process(delta: float) -> void:
    _cast_laser_beam()

func shoot() -> void:
    if _current_state != State.INACTIVE:
        return

    # Activate laser.
    show()
    set_physics_process(true)

    # Telegraph.
    _start_telegraph()
    yield(_tween, 'tween_all_completed')

    # Actual shot.
    _start_laser_shot()
    yield(_tween, 'tween_all_completed')

    # Wind down animation. Hitbox is disabled during wind down.
    _start_wind_down()
    yield(_tween, 'tween_all_completed')

    # Deactivate laser.
    set_physics_process(false)
    hide()

    if _current_state == State.CANCELLED:
        emit_signal('shot_cancelled')
    else:
        emit_signal('shot_finished')

    _current_state = State.INACTIVE

func cancel() -> void:
    _current_state = State.CANCELLED

func _cast_laser_beam() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact
    var collision_point_local = _get_collision_point_local()

    # Update the end of the line representing the beam.
    _beam_end.position = collision_point_local
    _outer_beam.points[1] = _beam_end.position
    _inner_beam.points[1] = _beam_end.position

    match _current_state:
        State.SHOOT:
            # Update collision shape.
            _hitbox_collision_shape.shape.extents = Vector2(
                collision_point_local.length() / 2.0, (MAX_WIDTH_OUTER / 2.0) - 1)
            _hitbox_collision_shape.rotation = collision_point_local.angle()
            _hitbox_collision_shape.position = collision_point_local / 2.0

        State.CANCELLED:
            _hitbox_collision_shape.set_deferred('disabled', true)
            hide()
            set_physics_process(false)

func _get_collision_point_local() -> Vector2:
    _raycast.force_raycast_update()

    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to

func _interpolate_beam_width(
    beam: Line2D,
    old: float,
    new: float,
    duration: float,
    delay: float = 0.0
) -> void:
    _tween.interpolate_property(
        beam, 'width', old, new, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT,
        delay)

func _interpolate_impact_sprite_radius(
    old: float,
    new: float,
    duration: float,
    delay: float = 0.0
) -> void:
    _tween.interpolate_property(
        _impact_sprite_mat, 'shader_param/impact_radius_uv', old, new, duration,
        Tween.TRANS_QUAD, Tween.EASE_IN_OUT, delay)

func _start_telegraph() -> void:
    var telegraph_width_outer := 1.5
    var telegraph_width_inner := 0.0
    var num_wobbles := 6

    _current_state = State.TELEGRAPH
    _hitbox_collision_shape.set_deferred('disabled', true)
    _outer_beam.modulate = TELEGRAPH_COLOR
    _beam_end.hide()

    _tween.remove_all()
    _setup_beam_wobble(telegraph_width_outer, telegraph_width_inner, num_wobbles)
    _tween.start()

func _start_laser_shot() -> void:
    var impact_sprite_radius_uv := MAX_IMPACT_SPRITE_RADIUS_UV
    var num_wobbles := 8

    if _current_state != State.CANCELLED:
        _current_state = State.SHOOT
        _hitbox_collision_shape.set_deferred('disabled', false)
        _impact_sparks.emitting = true
        _outer_beam.modulate = SHOT_COLOR
        _beam_end.show()

    _tween.remove_all()
    _setup_beam_wobble(MAX_WIDTH_OUTER, MAX_WIDTH_INNER, num_wobbles)
    _setup_impact_sprite_wobble(impact_sprite_radius_uv, num_wobbles)
    _tween.start()

func _start_wind_down() -> void:
    _hitbox_collision_shape.set_deferred('disabled', true)

    var current_radius_uv: float = _impact_sprite_mat.get_shader_param(
        'impact_radius_uv')

    _impact_sparks.emitting = false

    _tween.remove_all()
    _interpolate_beam_width(_outer_beam, _outer_beam.width, 0, WIND_DOWN_DURATION)
    _interpolate_beam_width(_inner_beam, _inner_beam.width, 0, WIND_DOWN_DURATION)
    _interpolate_impact_sprite_radius(current_radius_uv, 0, WIND_DOWN_DURATION)
    _tween.start()

func _setup_beam_wobble(
    outer_width: float,
    inner_width: float,
    num_wobbles: int
) -> void:
    var wobble_duration := SHOT_DURATION / float(num_wobbles)

    for i in range(num_wobbles):
        # Wobble outer beam.
        _interpolate_beam_width(
            _outer_beam, outer_width, outer_width - 1, wobble_duration,
            i * (SHOT_DURATION / float(num_wobbles)))
        _interpolate_beam_width(
            _outer_beam, outer_width - 1, outer_width, wobble_duration,
            (i+1) * (SHOT_DURATION / float(num_wobbles)))

        # Wobble inner beam.
        _interpolate_beam_width(
            _inner_beam, inner_width, inner_width - 1, wobble_duration,
            i * (SHOT_DURATION / float(num_wobbles)))
        _interpolate_beam_width(
            _inner_beam, inner_width - 1, inner_width, wobble_duration,
            (i+1) * (SHOT_DURATION / float(num_wobbles)))

func _setup_impact_sprite_wobble(
    impact_sprite_radius_uv: float,
    num_wobbles: int
) -> void:
    var wobble_duration := SHOT_DURATION / float(num_wobbles)

    for i in range(num_wobbles):
        _interpolate_impact_sprite_radius(
            impact_sprite_radius_uv, impact_sprite_radius_uv - 0.05,
            wobble_duration, i * (SHOT_DURATION / float(num_wobbles)))
        _interpolate_impact_sprite_radius(
            impact_sprite_radius_uv - 0.05, impact_sprite_radius_uv,
            wobble_duration, (i+1) * (SHOT_DURATION / float(num_wobbles)))
