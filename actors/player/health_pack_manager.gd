extends Node
class_name HealthPackManager

signal health_pack_consumed
signal health_pack_added

export(int) var max_num_health_packs := 3

var _num_health_packs := max_num_health_packs

func can_heal() -> bool:
    return num_health_packs() > 0

func num_health_packs() -> int:
    return _num_health_packs

func consume_health_pack() -> void:
    _num_health_packs = max(_num_health_packs - 1, 0)

    emit_signal('health_pack_consumed')

func add_health_pack() -> void:
    _num_health_packs = min(_num_health_packs + 1, max_num_health_packs)

    emit_signal('health_pack_added')
