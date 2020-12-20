extends Node
class_name HealthPackManager

signal health_pack_consumed
signal health_pack_added

export(int) var max_num_health_packs := 3

const SAVE_KEY := 'health_pack_manager'

var _num_health_packs := max_num_health_packs

func can_heal() -> bool:
    return num_health_packs() > 0

func num_health_packs() -> int:
    return _num_health_packs

func set_starting_health_packs() -> void:
    _num_health_packs = 1

    emit_signal('health_pack_consumed')

func consume_health_pack() -> void:
    _num_health_packs = max(_num_health_packs - 1, 0)

    emit_signal('health_pack_consumed')

func add_health_pack() -> void:
    _num_health_packs = min(_num_health_packs + 1, max_num_health_packs)

    emit_signal('health_pack_added')

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'num_health_packs': _num_health_packs,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var health_pack_manager_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('num_health_packs' in health_pack_manager_save_data)

    _num_health_packs = clamp(
        health_pack_manager_save_data['num_health_packs'], 0, max_num_health_packs)
