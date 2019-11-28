extends 'res://actors/enemies/state.gd'

# Particle effect that emits once the slime lands.
const LandingPuff := preload('res://sfx/LandingPuff.tscn')

# TODO: Use same gravity as player.
const GRAVITY: float = 700.0
const TERMINAL_VELOCITY: float = 20.0 * Util.TILE_SIZE

var _velocity := Vector2.ZERO

func enter(slime: Slime, previous_state_dict: Dictionary) -> void:
    _velocity = Vector2.ZERO

func exit(slime: Slime) -> void:
    pass

func update(slime: Slime, delta: float) -> Dictionary:
    if slime.is_on_floor():
        Util.spawn_particles(LandingPuff.instance(), slime)
        return {'new_state': Slime.State.WALK}

    _velocity.y = min(_velocity.y + GRAVITY * delta, TERMINAL_VELOCITY)
    slime.move(_velocity)

    return {'new_state': Slime.State.NO_CHANGE}