extends 'res://actors/enemies/state.gd'

# The duration of the stagger state in seconds.
const STAGGER_DURATION: float = 0.1

# The speed at which the drone is knocked back in pixels per second.
const STAGGER_SPEED: float = 10.0 * Util.TILE_SIZE

onready var _stagger_duration_timer: Timer = $StaggerDurationTimer

var _direction_from_hit := Vector2.ZERO

func _ready() -> void:
    _stagger_duration_timer.wait_time = STAGGER_DURATION
    _stagger_duration_timer.one_shot = true

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    _stagger_duration_timer.start()

    _direction_from_hit = previous_state_dict['direction_from_hit']
    assert(_direction_from_hit != null)

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    if _stagger_duration_timer.is_stopped():
        return {'new_state': WorkerDrone.State.IDLE}

    worker_drone.move(_direction_from_hit * STAGGER_SPEED)

    return {'new_state': WorkerDrone.State.NO_CHANGE}
