extends Control

onready var _health_nodes: HBoxContainer = $HealthNodes

var _current_health: int = 5

func set_health(new_health: int) -> void:
    assert(new_health <= _health_nodes.get_child_count())

    for health_node in _health_nodes.get_children():
        health_node.texture = Preloads.EmptyHealthTexture

    for idx in range(new_health):
        _health_nodes.get_child(idx).texture = Preloads.FullHealthTexture

func _on_health_changed(old_health: int, new_health: int) -> void:
    set_health(new_health)
