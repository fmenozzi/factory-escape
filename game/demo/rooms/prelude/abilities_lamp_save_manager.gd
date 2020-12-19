extends Node
class_name AbilitiesLampSaveManager

const SAVE_KEY := 'abilities_lamp'

var rested_at_lamp := false

onready var _room: Room = get_parent()

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'rested_at_lamp': rested_at_lamp,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var abilities_lamp_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('rested_at_lamp' in abilities_lamp_save_data)

    rested_at_lamp = abilities_lamp_save_data['rested_at_lamp']

    # If we've already rested at the lamp, disconnect the lamp rested and door
    # triggered signals and close the door.
    if rested_at_lamp:
        _room._lamp.disconnect('rested_at_lamp', _room, '_on_rested_at_lamp')
        _room._door_trigger.disconnect('body_entered', _room, '_on_player_entered_room')
        _room._closing_door.close()
