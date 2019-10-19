extends KinematicBody2D

export(Util.Direction) var direction := Util.Direction.RIGHT

const SPEED := 0.25 * Util.TILE_SIZE

enum State {
    WALK,
    STAGGER,
}
var _current_state: int = State.WALK

var _direction_from_hit: int = Util.Direction.NONE

onready var _flash_manager: Node = $FlashManager

onready var _health: Health = $Health
onready var _hurtbox: Area2D = $Hurtbox

onready var _edge_raycast_left: RayCast2D = $LedgeDetectorRaycasts/Left
onready var _edge_raycast_right: RayCast2D = $LedgeDetectorRaycasts/Right

func _ready() -> void:
    $AnimationPlayer.play('walk')
    _set_direction(direction)

    _hurtbox.connect('area_entered', self, '_on_hit_taken')

    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

func _physics_process(delta: float) -> void:
    match _current_state:
        State.WALK:
            if is_on_wall() or _is_touching_hazard() or _is_near_ledge():
                _set_direction(-1 * direction)
            _move(Vector2(direction * SPEED, 1))

        State.STAGGER:
            _move(Vector2(_direction_from_hit * SPEED * 30, 1))
            _current_state = State.WALK

func _move(velocity: Vector2) -> void:
    move_and_slide(velocity, Util.FLOOR_NORMAL)

func _set_direction(new_direction: int) -> void:
    direction = new_direction
    $Sprite.flip_h = (new_direction == Util.Direction.LEFT)

func _is_touching_hazard() -> bool:
    # Since there doesn't seem to be a way for a KinematicBody2D to query the
    # Area2Ds that overlap it, we just use the hurtbox Area2D to detect
    # collisions with hazards like spikes, taking advantage of the fact that the
    # collision shapes are the same.
    for area in _hurtbox.get_overlapping_areas():
        if Util.in_collision_layer(area, ['hazards']):
            return true
    return false

func _is_near_ledge() -> bool:
    var near_left := not _edge_raycast_left.is_colliding()
    var near_right := not _edge_raycast_right.is_colliding()

    return (near_left and not near_right) or (near_right and not near_left)

func _on_hit_taken(hitbox: Area2D) -> void:
    if Util.in_collision_layer(hitbox, ['hazards']):
        return

    # TODO: Do we need to use the RID method to ensure no hits get
    #       double-counted? Is there a way to automatically detect whether this
    #       has happened in the meantime?
    _health.take_damage(1)
    _flash_manager.start_flashing()
    _direction_from_hit = Util.direction(hitbox, self)
    _current_state = State.STAGGER

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('SLIME HIT (new health: ', new_health, ')')

func _on_died() -> void:
    print('SLIME DIED')
    queue_free()