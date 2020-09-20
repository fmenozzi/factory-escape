extends Node

func spawn_dust_puff_at(global_pos: Vector2) -> void:
    var dust_puff := Preloads.DustPuff.instance()

    _get_temporary_nodes_node().add_child(dust_puff)

    dust_puff.global_position = global_pos
    dust_puff.start_and_queue_free()

func _get_temporary_nodes_node() -> Node2D:
    var nodes_in_temporary_nodes_node_group := \
        get_tree().get_nodes_in_group('temporary_nodes_node')
    assert(nodes_in_temporary_nodes_node_group.size() == 1)
    return nodes_in_temporary_nodes_node_group[0]
