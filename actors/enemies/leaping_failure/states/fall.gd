extends 'res://actors/enemies/state.gd'

const TERMINAL_VELOCITY: float = 20.0 * Util.TILE_SIZE
const MAX_JUMP_HEIGHT: float = 4.0 * Util.TILE_SIZE
const JUMP_DURATION: float = 0.35
const HORIZONTAL_SPEED: float = 8.0 * Util.TILE_SIZE

var _velocity := Vector2.ZERO
var _gravity: float
var _aggro: bool

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _gravity = 2 * MAX_JUMP_HEIGHT / pow(JUMP_DURATION, 2)
    _velocity.x = HORIZONTAL_SPEED * failure.direction
    _velocity.y = 0.0

    assert('aggro' in previous_state_dict)
    _aggro = previous_state_dict['aggro']

    failure.get_animation_player().play('fall')

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if failure.is_on_floor():
        failure.emit_dust_puff()
        if _aggro:
            return {'new_state': LeapingFailure.State.FAST_WALK}
        else:
            return {'new_state': LeapingFailure.State.WALK}

    # Fall due to gravity.
    _velocity.y = min(_velocity.y + _gravity * delta, TERMINAL_VELOCITY)

    failure.move(_velocity)

    return {'new_state': LeapingFailure.State.NO_CHANGE}
