extends 'res://actors/enemies/enemy_state.gd'

var _next_move_state: int = -1

onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.one_shot = true

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    assert('pause_time' in previous_state_dict)
    var pause_time: float = previous_state_dict['pause_time']
    assert(pause_time >= 0.0)

    assert('next_move_state' in previous_state_dict)
    _next_move_state = previous_state_dict['next_move_state']
    assert(_next_move_state in [
        LeapingFailure.State.EXPAND,
        LeapingFailure.State.CONTRACT,
        LeapingFailure.State.EXPAND_FAST,
        LeapingFailure.State.CONTRACT_FAST,
    ])

    _timer.wait_time = pause_time
    _timer.start()

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if _timer.is_stopped():
        return {'new_state': _next_move_state}

    # Make sure we move down slightly to snap to moving platforms.
    failure.move(Vector2(0, 10))

    return {'new_state': LeapingFailure.State.NO_CHANGE}
