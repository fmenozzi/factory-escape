extends Control

onready var _health_pack_nodes: VBoxContainer = $HBoxContainer/HealthPackNodes

var _current_health_packs := 3

func _ready() -> void:
    set_health_packs(_current_health_packs)

func set_health_packs(new_health_packs: int) -> void:
    assert(new_health_packs <= _health_pack_nodes.get_child_count())

    for health_pack_node in _health_pack_nodes.get_children():
        health_pack_node.texture = Preloads.EmptyHealthPackTexture

    # Health pack nodes fill up from the bottom, so count backwards for child
    # indices.
    for idx in range(new_health_packs - 1, -1, -1):
        _health_pack_nodes.get_child(idx).texture = Preloads.FullHealthPackTexture

    _current_health_packs = new_health_packs
