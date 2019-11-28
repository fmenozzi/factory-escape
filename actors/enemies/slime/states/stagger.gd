extends 'res://actors/enemies/state.gd'

# The duration of the stagger state in seconds.
const STAGGER_DURATION: float = 0.1

# The speed at which the slime is knocked back in pixels per second.
const STAGGER_SPEED: float = 10.0 * Util.TILE_SIZE

onready var _stagger_duration_timer: Timer = $StaggerDurationTimer

var _velocity := Vector2.ZERO
var _direction_from_hit: int = Util.Direction.NONE

func _ready() -> void:
    _stagger_duration_timer.wait_time = STAGGER_DURATION
    _stagger_duration_timer.one_shot = true

func enter(slime, previous_state_dict: Dictionary) -> void:
    _stagger_duration_timer.start()

    _direction_from_hit = previous_state_dict['direction_from_hit']
    assert(_direction_from_hit != null)

func exit(slime) -> void:
    pass

func update(slime, delta: float) -> Dictionary:
    if _stagger_duration_timer.is_stopped():
        return {'new_state': Slime.State.WALK}

    slime.move(Vector2(_direction_from_hit * 10.0 * slime.SPEED, 1))

    return {'new_state': Slime.State.NO_CHANGE}