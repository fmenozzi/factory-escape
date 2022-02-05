extends Node
class_name ClosingDoorWithSwitchSectorFiveSaveManager

onready var _closing_door_with_switch_sector_five = get_parent()
onready var _save_key: String = get_parent().get_path()

var is_open := false

func get_save_data() -> Array:
    return [_save_key, {
        'is_open': is_open
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var closing_door_with_switch_save_data: Dictionary = all_save_data[_save_key]
    assert('is_open' in closing_door_with_switch_save_data)

    is_open = closing_door_with_switch_save_data['is_open']

    if is_open:
        _closing_door_with_switch_sector_five._closing_door.set_opened()
        _closing_door_with_switch_sector_five._switch.reset_state_to(Switch.State.PRESSED)
