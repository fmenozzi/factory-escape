extends KinematicBody2D
class_name LeapingFailure

export(Util.Direction) var direction := Util.Direction.RIGHT

const SPEED := 0.5 * Util.TILE_SIZE

enum State {
    NO_CHANGE,
    WALK,
    GROUND_STAGGER,
    FALL,
    RETURN_TO_LEDGE,
}

onready var STATES := {
    State.WALK:            $States/Walk,
    State.GROUND_STAGGER:  $States/GroundStagger,
    State.FALL:            $States/Fall,
    State.RETURN_TO_LEDGE: $States/ReturnToLedge,
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _sprite: Sprite = $Sprite
onready var _dust_puff: Particles2D = $DustPuff

onready var _edge_raycast_left: RayCast2D = $LedgeDetectorRaycasts/Left
onready var _edge_raycast_right: RayCast2D = $LedgeDetectorRaycasts/Right

func _ready() -> void:
    set_direction(direction)

    _current_state_enum = State.FALL
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func set_direction(new_direction: int) -> void:
    direction = new_direction
    _sprite.flip_h = (new_direction == Util.Direction.LEFT)

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()
    if is_on_floor():
        _change_state({
            'new_state': State.GROUND_STAGGER,
            'direction_from_hit': Util.direction(player, self),
        })

func move(velocity: Vector2, snap: Vector2 = Util.SNAP) -> void:
    .move_and_slide_with_snap(velocity, snap, Util.FLOOR_NORMAL)

func is_off_ledge() -> bool:
    var off_left := not _edge_raycast_left.is_colliding()
    var off_right := not _edge_raycast_right.is_colliding()

    return (off_left and not off_right) or (off_right and not off_left)

func emit_dust_puff() -> void:
    _dust_puff.restart()

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

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('LEAPING FAILURE HIT (new health: ', new_health, ')')

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    print('LEAPING FAILURE DIED')
    queue_free()
