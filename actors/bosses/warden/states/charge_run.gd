extends 'res://actors/enemies/enemy_state.gd'

# The maximum distance the warden will continue to travel once it misses the
# player.
const MAX_CHARGE_MISS_DISTANCE: float = 2.0 * Util.TILE_SIZE

var _direction_to_player: int = Util.Direction.NONE
var _player: Player
var _run_miss_distance_travelled := 0.0

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    assert('direction_to_player' in previous_state_dict)
    _direction_to_player = previous_state_dict['direction_to_player']
    assert(_direction_to_player != null)

    _player = Util.get_player()
    _run_miss_distance_travelled = 0.0

    warden.set_direction(_direction_to_player)
    warden.get_animation_player().play('charge_run')

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    var physics_manager := warden.get_physics_manager()
    var run_speed := physics_manager.get_run_speed()

    warden.move(Vector2(_direction_to_player, 0) * run_speed)

    if _warden_missed_player(warden):
        _run_miss_distance_travelled += run_speed * delta
        if _run_miss_distance_travelled > MAX_CHARGE_MISS_DISTANCE:
            return {'new_state': Warden.State.CHARGE_RECOVER_SLIDE}

    if warden.is_on_wall():
        return {'new_state': Warden.State.CHARGE_IMPACT}

    return {'new_state': Warden.State.NO_CHANGE}

func _warden_missed_player(warden: Warden) -> bool:
    var original_direction := _direction_to_player
    var current_direction := Util.direction(warden, _player)

    return original_direction + current_direction == 0
