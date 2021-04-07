extends 'res://actors/enemies/enemy_state.gd'

var _next_move_state: int = -1

onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.one_shot = true

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    assert('wait_time' in previous_state_dict)
    var wait_time: float = previous_state_dict['wait_time']
    assert(wait_time >= 0.0)

    assert('next_move_state' in previous_state_dict)
    _next_move_state = previous_state_dict['next_move_state']
    assert(_next_move_state in [
        SluggishFailure.State.EXPAND,
        SluggishFailure.State.CONTRACT
    ])

    _timer.wait_time = wait_time
    _timer.start()

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    if _timer.is_stopped():
        return {'new_state': _next_move_state}

    # Make sure we move down slightly to snap to moving platforms.
    failure.move(Vector2(0, 10))

    return {'new_state': SluggishFailure.State.NO_CHANGE}
