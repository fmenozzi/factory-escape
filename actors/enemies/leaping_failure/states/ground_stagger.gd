extends 'res://actors/enemies/enemy_state.gd'

# The duration of the stagger state in seconds.
const STAGGER_DURATION: float = 0.1

# The speed at which the failure is knocked back in pixels per second.
const STAGGER_SPEED: float = 2.5 * Util.TILE_SIZE

onready var _stagger_duration_timer: Timer = $StaggerDurationTimer

var _direction_from_hit: int = Util.Direction.NONE

func _ready() -> void:
    _stagger_duration_timer.wait_time = STAGGER_DURATION
    _stagger_duration_timer.one_shot = true

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _stagger_duration_timer.start()

    assert('direction_from_hit' in previous_state_dict)
    _direction_from_hit = previous_state_dict['direction_from_hit']
    assert(_direction_from_hit != null)

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if _stagger_duration_timer.is_stopped():
        # Assume we're in combat if the failure has been staggered.
        return {'new_state': LeapingFailure.State.FAST_WALK}

    failure.move(Vector2(_direction_from_hit * STAGGER_SPEED, 1))

    return {'new_state': LeapingFailure.State.NO_CHANGE}
