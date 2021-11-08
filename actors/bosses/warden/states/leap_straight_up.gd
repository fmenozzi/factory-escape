extends 'res://actors/enemies/enemy_state.gd'

const GRAVITY_MULTIPLIER := 1.5

var _velocity := Vector2.ZERO

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    _velocity.y = warden.get_physics_manager().get_max_jump_velocity()

    # Pitch the leap sound up a bit since it's a bit faster than the normal
    # version.
    var audio_player: AudioStreamPlayer = warden.get_sound_manager() \
        .get_player(WardenSoundManager.Sounds.TAKEOFF) \
        .get_player()
    audio_player.pitch_scale = 1.2
    audio_player.play()

func exit(warden: Warden) -> void:
    # Reset pitch scale.
    warden.get_sound_manager() \
        .get_player(WardenSoundManager.Sounds.TAKEOFF) \
        .get_player() \
        .pitch_scale = 1.0

func update(warden: Warden, delta: float) -> Dictionary:
    # Move due to gravity.
    var gravity := warden.get_physics_manager().get_gravity()
    _velocity.y += GRAVITY_MULTIPLIER * gravity * delta

    # Don't snap while jumping.
    warden.move(_velocity, Util.NO_SNAP)

    if warden.is_on_floor():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
