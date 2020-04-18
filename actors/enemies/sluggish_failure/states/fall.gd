extends 'res://actors/enemies/state.gd'

# TODO: Use same gravity as player.
const GRAVITY: float = 700.0
const TERMINAL_VELOCITY: float = 20.0 * Util.TILE_SIZE

var _velocity := Vector2.ZERO

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    _velocity = Vector2.ZERO

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    if failure.is_on_floor():
        failure.emit_dust_puff()
        return {'new_state': SluggishFailure.State.WALK}

    _velocity.y = min(_velocity.y + GRAVITY * delta, TERMINAL_VELOCITY)
    failure.move(_velocity)

    return {'new_state': SluggishFailure.State.NO_CHANGE}
