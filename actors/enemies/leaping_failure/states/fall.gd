extends 'res://actors/enemies/state.gd'

# TODO: Use same gravity as player.
const GRAVITY: float = 700.0
const TERMINAL_VELOCITY: float = 20.0 * Util.TILE_SIZE

var _velocity := Vector2.ZERO

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _velocity = Vector2.ZERO

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if failure.is_on_floor():
        failure.emit_dust_puff()
        return {'new_state': LeapingFailure.State.WALK}

    _velocity.y = min(_velocity.y + GRAVITY * delta, TERMINAL_VELOCITY)
    failure.move(_velocity)

    return {'new_state': LeapingFailure.State.NO_CHANGE}
