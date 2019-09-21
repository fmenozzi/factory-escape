extends Control

const EMPTY_HEALTH_TEXTURE := preload('res://assets/health-node-empty.png')
const FULL_HEALTH_TEXTURE := preload('res://assets/health-node-full.png')

onready var NUM_HEALTH_NODES: int = $HealthNodes.get_child_count()

var _current_health: int = 5

func set_health(new_health: int) -> void:
    assert new_health <= NUM_HEALTH_NODES

    for health_node in $HealthNodes.get_children():
        health_node.texture = EMPTY_HEALTH_TEXTURE

    for idx in range(new_health):
        $HealthNodes.get_child(idx).texture = FULL_HEALTH_TEXTURE

func _on_health_changed(old_health: int, new_health: int) -> void:
    set_health(new_health)