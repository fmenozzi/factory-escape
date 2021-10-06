extends 'res://actors/enemies/enemy_state.gd'

onready var _rng_table := {
    range(1, 11):   Warden.State.BACKSTEP,
    range(11, 21):  Warden.State.LEAP_TO_CENTER,
    range(21, 31):  Warden.State.CHARGE,
    range(31, 51):  Warden.State.SPAWN_PROJECTILES,
    range(51, 71):  Warden.State.COMBO_LIGHTNING_FLOOR,
    range(71, 81):  Warden.State.COMBO_LEAP,
    range(81, 91):  Warden.State.COMBO_CHARGE_BACKSTEP,
    range(91, 101): Warden.State.COMBO_CHARGE_LEAP_TO_CENTER,
}

onready var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _rng.randomize()

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    pass

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    var rng_value := _rng.randi_range(1, 100)
    for rng_range in _rng_table:
        if rng_value in rng_range:
            return {'new_state': _rng_table[rng_range]}

    return {'new_state': Warden.State.NO_CHANGE}
