extends 'res://actors/enemies/enemy_state.gd'

const MAX_NUM_RETRIES := 5

enum RngTableKey {
    PLAYER_NEAR,
    PLAYER_FAR,
}

onready var rng_tables := {
    RngTableKey.PLAYER_NEAR: {
        Warden.State.COMBO_LEAP:     10,
        Warden.State.BACKSTEP:       30,
        Warden.State.LEAP_TO_CENTER: 30,
        Warden.State.STOMP:          30,
    },

    RngTableKey.PLAYER_FAR: {
        Warden.State.BACKSTEP:                    10,
        Warden.State.LEAP_TO_CENTER:              10,
        Warden.State.CHARGE:                      20,
        Warden.State.SPAWN_PROJECTILES:           10,
        Warden.State.COMBO_LIGHTNING_FLOOR:       20,
        Warden.State.COMBO_LEAP:                  10,
        Warden.State.COMBO_CHARGE_BACKSTEP:       10,
        Warden.State.COMBO_CHARGE_LEAP_TO_CENTER: 10,
    },
}

onready var _rng := RandomNumberGenerator.new()

var _range_tables := {}
var _last_attack := -1

func _ready() -> void:
    _rng.randomize()

    # Ensure probabilities in each rng table add up to 100.
    for rng_table in rng_tables.values():
        var rng_sum := 0
        for rng_value in rng_table.values():
            rng_sum += rng_value
        assert(rng_sum == 100)

    # Construct the range tables (used for selecting attacks from a random int)
    # from each rng table's probability values.
    for rng_table_key in rng_tables:
        var rng_table: Dictionary = rng_tables[rng_table_key]
        var range_table := {}
        var range_start := 1
        for state in rng_table:
            var rng_value: int = rng_table[state]
            range_table[range(range_start, range_start + rng_value)] = state
            range_start += rng_value
        _range_tables[rng_table_key] = range_table

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    pass

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    var next_attack := _get_next_attack(warden)

    return {'new_state': next_attack}

func _get_next_attack(warden: Warden) -> int:
    # If the next attack is the same as the previous one, retry attack selection
    # (up to MAX_NUM_RETRIES times) until a different one is selected.
    var next_attack := _select_random_attack(warden)
    if next_attack == _last_attack:
        for i in range(MAX_NUM_RETRIES):
            next_attack = _select_random_attack(warden)
            if next_attack == _last_attack:
                continue
    _last_attack = next_attack
    return next_attack

func _select_random_attack(warden: Warden) -> int:
    var rng_table_key := _get_rng_table_key(warden)
    var range_table: Dictionary = _range_tables[rng_table_key]

    var rng_value := _rng.randi_range(1, 100)
    for rng_range in range_table:
        if rng_value in rng_range:
            return range_table[rng_range]

    return Warden.State.NO_CHANGE

func _get_rng_table_key(warden: Warden) -> int:
    if warden.player_is_near():
        return RngTableKey.PLAYER_NEAR
    else:
        return RngTableKey.PLAYER_FAR
