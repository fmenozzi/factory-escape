extends 'res://actors/enemies/enemy_state.gd'

onready var rng_table := {
    Warden.State.BACKSTEP:                    10,
    Warden.State.LEAP_TO_CENTER:              10,
    Warden.State.STOMP:                       10,
    Warden.State.CHARGE:                      10,
    Warden.State.SPAWN_PROJECTILES:           10,
    Warden.State.COMBO_LIGHTNING_FLOOR:       20,
    Warden.State.COMBO_LEAP:                  10,
    Warden.State.COMBO_CHARGE_BACKSTEP:       10,
    Warden.State.COMBO_CHARGE_LEAP_TO_CENTER: 10,
}

onready var _rng := RandomNumberGenerator.new()

var _range_table := {}

func _ready() -> void:
    _rng.randomize()

    # Ensure probabilities add up to 100.
    var rng_sum := 0
    for rng_value in rng_table.values():
        rng_sum += rng_value
    assert(rng_sum == 100)

    # Construct the range table (used for selecting attacks from a random int)
    # from the rng table probability values.
    var range_start := 1
    for state in rng_table:
        var rng_value: int = rng_table[state]
        _range_table[range(range_start, range_start + rng_value)] = state
        range_start += rng_value

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    pass

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    var rng_value := _rng.randi_range(1, 100)
    for rng_range in _range_table:
        if rng_value in rng_range:
            return {'new_state': _range_table[rng_range]}

    return {'new_state': Warden.State.NO_CHANGE}
