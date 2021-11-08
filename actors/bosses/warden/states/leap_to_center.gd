extends 'res://actors/enemies/enemy_state.gd'

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.emit_dust_puff_takeoff()
    warden.get_sound_manager().play(WardenSoundManager.Sounds.TAKEOFF)

    _velocity = _calculate_velocity(warden)

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    # Apply gravity with terminal velocity.
    var physics_manager := warden.get_physics_manager()
    _velocity.y = min(
        _velocity.y + physics_manager.get_gravity() * delta,
        physics_manager.get_terminal_velocity())
    warden.move(_velocity, Util.NO_SNAP)

    if warden.is_on_floor():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}

func _calculate_velocity(warden: Warden) -> Vector2:
    var dest := warden.get_room_center_global_position()
    var disp := dest - warden.global_position

    # The height from the higher of the two points to the highest point in the
    # arc.
    var h := 4.0 * Util.TILE_SIZE
    var g := warden.get_physics_manager().get_gravity()
    var t := sqrt(2 * h / g)

    var velocity := Vector2.ZERO
    velocity.x = disp.x / float(2 * t)
    velocity.y = -sqrt(2 * h * g)
    return velocity
