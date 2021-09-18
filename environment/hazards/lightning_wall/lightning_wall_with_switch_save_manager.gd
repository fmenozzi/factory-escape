extends Node
class_name LightningWallWithSwitchSaveManager

onready var _lightning_wall_with_switch = get_parent()
onready var _save_key: String = get_parent().get_path()

var is_active := true

func get_save_data() -> Array:
    return [_save_key, {
        'is_active': is_active
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var lightning_wall_with_switch_save_data: Dictionary = all_save_data[_save_key]
    assert('is_active' in lightning_wall_with_switch_save_data)

    is_active = lightning_wall_with_switch_save_data['is_active']

    if not is_active:
        _lightning_wall_with_switch._lightning_wall.dissipate()
        _lightning_wall_with_switch._switch.reset_state_to(Switch.State.PRESSED)
