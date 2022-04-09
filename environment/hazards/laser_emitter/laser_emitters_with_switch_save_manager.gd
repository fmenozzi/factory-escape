extends Node
class_name LaserEmittersWithSwitchSaveManager

onready var _laser_emitters_with_switch = get_parent()
onready var _save_key: String = get_parent().get_path()

var is_active := true

func get_save_data() -> Array:
    return [_save_key, {
        'is_active': is_active
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var laser_emitters_with_switch_save_data: Dictionary = all_save_data[_save_key]
    assert('is_active' in laser_emitters_with_switch_save_data)

    is_active = laser_emitters_with_switch_save_data['is_active']

    if not is_active:
        _laser_emitters_with_switch._laser_emitter_group.deactivate()
        _laser_emitters_with_switch._switch.reset_state_to(Switch.State.PRESSED)
