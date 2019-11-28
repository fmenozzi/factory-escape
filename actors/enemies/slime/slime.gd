extends KinematicBody2D
class_name Slime

export(Util.Direction) var direction := Util.Direction.RIGHT

const SPEED := 0.25 * Util.TILE_SIZE

enum State {
    NO_CHANGE,
    WALK,
    STAGGER,
    FALL,
}

onready var STATES := {
    State.WALK:    $States/Walk,
    State.STAGGER: $States/Stagger,
    State.FALL:    $States/Fall,
}

var _current_state: Node = null
var _current_state_enum: int = -1

var _direction_from_hit: int = Util.Direction.NONE

onready var _flash_manager: Node = $FlashManager

onready var _health: Health = $Health
onready var _hurtbox: Area2D = $Hurtbox

onready var _edge_raycast_left: RayCast2D = $LedgeDetectorRaycasts/Left
onready var _edge_raycast_right: RayCast2D = $LedgeDetectorRaycasts/Right

func _ready() -> void:
    set_direction(direction)

    _current_state_enum = State.WALK
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()
    _change_state({
        'new_state': State.STAGGER,
        'direction_from_hit': Util.direction(player, self),
    })

func move(velocity: Vector2) -> void:
    move_and_slide(velocity, Util.FLOOR_NORMAL)

func _change_state(new_state_dict: Dictionary) -> void:
    var old_state_enum := _current_state_enum
    var new_state_enum: int = new_state_dict['new_state']

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = old_state_enum

    _current_state.exit(self)
    _current_state_enum = new_state_enum
    _current_state = STATES[new_state_enum]
    _current_state.enter(self, new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    $Sprite.flip_h = (new_direction == Util.Direction.LEFT)

func is_touching_hazard() -> bool:
    # Since there doesn't seem to be a way for a KinematicBody2D to query the
    # Area2Ds that overlap it, we just use the hurtbox Area2D to detect
    # collisions with hazards like spikes, taking advantage of the fact that the
    # collision shapes are the same.
    for area in _hurtbox.get_overlapping_areas():
        if Util.in_collision_layer(area, ['hazards']):
            return true
    return false

func is_near_ledge() -> bool:
    var near_left := not _edge_raycast_left.is_colliding()
    var near_right := not _edge_raycast_right.is_colliding()

    return (near_left and not near_right) or (near_right and not near_left)

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('SLIME HIT (new health: ', new_health, ')')

func _on_died() -> void:
    print('SLIME DIED')
    queue_free()