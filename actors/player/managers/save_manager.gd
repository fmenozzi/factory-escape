extends Node
class_name PlayerSaveManager

var last_saved_global_position: Vector2
var last_saved_direction_to_lamp: int = Util.Direction.RIGHT
var has_rested_at_any_lamp: bool = false
var has_completed_intro_fall_sequence: bool = false

func get_save_data() -> Array:
    return ['player', {
        'global_position_x': last_saved_global_position.x,
        'global_position_y': last_saved_global_position.y,
        'direction_to_lamp': last_saved_direction_to_lamp,
        'has_rested_at_any_lamp': has_rested_at_any_lamp,
        'has_completed_intro_fall_sequence': has_completed_intro_fall_sequence,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not 'player' in all_save_data:
        return

    var player_save_data: Dictionary = all_save_data['player']
    assert('global_position_x' in player_save_data)
    assert('global_position_y' in player_save_data)
    assert('direction_to_lamp' in player_save_data)
    assert('has_rested_at_any_lamp' in player_save_data)
    assert('has_completed_intro_fall_sequence' in player_save_data)

    last_saved_global_position.x = player_save_data['global_position_x']
    last_saved_global_position.y = player_save_data['global_position_y']
    last_saved_direction_to_lamp = player_save_data['direction_to_lamp']
    has_rested_at_any_lamp = player_save_data['has_rested_at_any_lamp']
    has_completed_intro_fall_sequence = player_save_data['has_completed_intro_fall_sequence']

    var player = Util.get_player()
    player.global_position = last_saved_global_position
    player.set_direction(last_saved_direction_to_lamp)
