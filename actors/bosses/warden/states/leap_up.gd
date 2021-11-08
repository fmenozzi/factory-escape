extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO
var _speed_multiplier := 1.0

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.emit_dust_puff_takeoff()
    warden.get_sound_manager().play(WardenSoundManager.Sounds.TAKEOFF)

    _velocity.y = warden.get_physics_manager().get_max_jump_velocity()
    _speed_multiplier = rand_range(0.7, 1.2)

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    # Switch to 'fall' state once we reach apex of jump.
    if _velocity.y >= 0:
        return {
            'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE,
            'speed_multiplier': _speed_multiplier,
        }

    var physics_manager := warden.get_physics_manager()
    var speed := physics_manager.get_horizontal_jump_speed()
    _velocity.x = speed * _speed_multiplier * warden.direction

    # Move due to gravity.
    var gravity := physics_manager.get_gravity()
    _velocity.y += gravity * delta

    # Don't snap while jumping.
    warden.move(_velocity, Util.NO_SNAP)

    return {'new_state': Warden.State.NO_CHANGE}
