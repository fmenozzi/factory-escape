extends Node2D

# The maximum length of the laser beam.
const MAX_LENGTH: float = 100.0 * Util.TILE_SIZE

# The maximum width of the laser beam.
const MAX_WIDTH: float = 4.0

# The color of the laser beam during the telegraph phase.
const TELEGRAPH_COLOR: Color = Color('ff4f78')

# The amount of time the laser spends telegraphing the subsequent shot, during
# which the player cannot be harmed.
const TELEGRAPH_DURATION: float = 1.0

# The color of the laser beam during the shoot phase.
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
}

var _current_state: int = State.INACTIVE

onready var _raycast: RayCast2D = $RayCast2D
onready var _line: Line2D = $Line2D
onready var _tween: Tween = $WidthTween
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
    _raycast.cast_to = Vector2(MAX_LENGTH, 0)

    _line.width = MAX_WIDTH
    _line.add_point(Vector2.ZERO)
    _line.add_point(_raycast.cast_to)

    _hitbox_collision_shape.shape = RectangleShape2D.new()
    _hitbox_collision_shape.shape.extents = Vector2.ZERO

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
    _hitbox_collision_shape.set_deferred('disabled', true)
    _animate_beam_width(_line.width, 0, WIND_DOWN_DURATION)
    yield(_tween, 'tween_all_completed')

    # Deactivate laser.
    set_physics_process(false)
    hide()

    _current_state = State.INACTIVE

func _cast_laser_beam() -> void:
    # Get the local coordinates of the point where the laser actually makes
    # contact
    var collision_point_local = _get_collision_point_local()

    # Update the end of the line representing the beam.
    _line.points[1] = collision_point_local

    if _current_state == State.SHOOT:
        # Update collision shape.
        _hitbox_collision_shape.shape.extents = Vector2(
            collision_point_local.length() / 2.0, (MAX_WIDTH / 2.0) - 1)
        _hitbox_collision_shape.rotation = collision_point_local.angle()
        _hitbox_collision_shape.position = collision_point_local / 2.0

func _get_collision_point_local() -> Vector2:
    _raycast.force_raycast_update()

    if _raycast.is_colliding():
        return self.to_local(_raycast.get_collision_point())
    else:
        return _raycast.cast_to

func _animate_beam_width(old: float, new: float, duration: float) -> void:
    _tween.remove_all()
    _tween.interpolate_property(_line, 'width', old, new, duration)
    _tween.start()

func _start_telegraph() -> void:
    var telegraph_width := 1.5
    var num_wobbles := 6

    _current_state = State.TELEGRAPH
    _hitbox_collision_shape.set_deferred('disabled', true)
    _line.modulate = TELEGRAPH_COLOR

    _wobble(telegraph_width, num_wobbles)

func _start_laser_shot() -> void:
    var shot_width := MAX_WIDTH
    var num_wobbles := 8

    _current_state = State.SHOOT
    _hitbox_collision_shape.set_deferred('disabled', false)
    _line.modulate = SHOT_COLOR

    _wobble(shot_width, num_wobbles)

func _wobble(shot_width: float, num_wobbles: int) -> void:
    _tween.remove_all()

    for i in range(num_wobbles):
        _tween.interpolate_property(
            _line, 'width', shot_width, shot_width - 1,
            SHOT_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, i * (SHOT_DURATION / float(num_wobbles)))
        _tween.interpolate_property(
            _line, 'width', shot_width - 1, shot_width,
            SHOT_DURATION / float(num_wobbles), Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT, (i+1) * (SHOT_DURATION / float(num_wobbles)))

    _tween.start()
