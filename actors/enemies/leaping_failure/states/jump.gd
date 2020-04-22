extends 'res://actors/enemies/state.gd'

const TERMINAL_VELOCITY: float = 20.0 * Util.TILE_SIZE
const MAX_JUMP_HEIGHT: float = 4.0 * Util.TILE_SIZE
const JUMP_DURATION: float = 0.35
const HORIZONTAL_SPEED: float = 8.0 * Util.TILE_SIZE

var _velocity := Vector2.ZERO
var _gravity: float

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _gravity = 2 * MAX_JUMP_HEIGHT / pow(JUMP_DURATION, 2)
    _velocity.x = HORIZONTAL_SPEED * failure.direction
    _velocity.y = -sqrt(2 * _gravity * MAX_JUMP_HEIGHT)

    failure.emit_dust_puff()

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    # Switch to 'fall' state once we reach apex of jump.
    if _velocity.y >= 0:
        return {
            'new_state': LeapingFailure.State.FALL,
            'aggro': true,
        }

    # Move due to gravity.
    _velocity.y += _gravity * delta

    # Don't snap while jumping.
    failure.move(_velocity, Util.NO_SNAP)

    return {'new_state': LeapingFailure.State.NO_CHANGE}
