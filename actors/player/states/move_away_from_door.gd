extends 'res://actors/player/states/player_state.gd'

const MOVEMENT_SPEED := 64

var _door_area: Area2D = null
var _direction_to_warden: int = Util.Direction.NONE

func enter(player: Player, previous_state_dict: Dictionary) -> void:
    assert('door_area' in previous_state_dict)
    assert(previous_state_dict['door_area'] is Area2D)
    _door_area = previous_state_dict['door_area']

    assert('warden' in previous_state_dict)
    assert(previous_state_dict['warden'] is Warden)
    _direction_to_warden = Util.direction(player, previous_state_dict['warden'])

func exit(player: Player) -> void:
    pass

func handle_input(player: Player, event: InputEvent) -> Dictionary:
    return {'new_state': Player.State.NO_CHANGE}

func update(player: Player, delta: float) -> Dictionary:
    player.move(
        Vector2(-_direction_to_warden * MOVEMENT_SPEED, player.get_slight_downward_move()))

    if not _door_area.get_overlapping_bodies().has(player):
        return {'new_state': Player.State.IDLE}

    return {'new_state': Player.State.NO_CHANGE}
