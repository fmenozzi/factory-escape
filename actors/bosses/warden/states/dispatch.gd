extends 'res://actors/enemies/enemy_state.gd'

var _rng := RandomNumberGenerator.new()

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    pass

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    match _rng.randi_range(1, 6):
        1:
            return {'new_state': Warden.State.BACKSTEP}
        2:
            return {'new_state': Warden.State.LEAP}
        3:
            return {'new_state': Warden.State.LEAP_TO_CENTER}
        4:
            return {'new_state': Warden.State.CHARGE}
        5:
            return {'new_state': Warden.State.COMBO_LIGHTNING_FLOOR}
        6:
            return {'new_state': Warden.State.SPAWN_PROJECTILES}

    return {'new_state': Warden.State.NO_CHANGE}
