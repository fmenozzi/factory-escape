extends Node

func spawn_dust_puff_at(global_pos: Vector2) -> void:
    var dust_puff: Node2D = Preloads.DustPuff.instance()

    _get_temporary_nodes_node().add_child(dust_puff)

    dust_puff.global_position = global_pos
    dust_puff.start_and_queue_free()

func spawn_warden_dust_puff_land_at(global_pos: Vector2) -> void:
    var dust_puff_warden: Node2D = Preloads.DustPuffWardenLand.instance()

    _get_temporary_nodes_node().add_child(dust_puff_warden)

    dust_puff_warden.global_position = global_pos
    dust_puff_warden.start_and_queue_free()

func spawn_warden_dust_puff_takeoff_at(global_pos: Vector2) -> void:
    var dust_puff_warden: Node2D = Preloads.DustPuffWardenTakeoff.instance()

    _get_temporary_nodes_node().add_child(dust_puff_warden)

    dust_puff_warden.global_position = global_pos
    dust_puff_warden.start_and_queue_free()

func spawn_warden_dust_puff_slide_at(global_pos: Vector2, direction: int) -> void:
    var dust_puff_warden: Node2D = Preloads.DustPuffWardenSlide.instance()

    _get_temporary_nodes_node().add_child(dust_puff_warden)

    dust_puff_warden.global_position = global_pos
    dust_puff_warden.start_and_queue_free(direction)

func spawn_warden_dust_puff_impact_at(global_pos: Vector2, direction: int) -> void:
    var dust_puff_warden: Node2D = Preloads.DustPuffWardenImpact.instance()

    _get_temporary_nodes_node().add_child(dust_puff_warden)

    dust_puff_warden.global_position = global_pos
    dust_puff_warden.start_and_queue_free(direction)

func spawn_debris_at(global_pos: Vector2) -> void:
    var debris: Particles2D = Preloads.Debris.instance()

    _get_temporary_nodes_node().add_child(debris)

    debris.global_position = global_pos
    debris.start_and_queue_free()

func _get_temporary_nodes_node() -> Node2D:
    var nodes_in_temporary_nodes_node_group := \
        get_tree().get_nodes_in_group('temporary_nodes_node')
    assert(nodes_in_temporary_nodes_node_group.size() == 1)
    return nodes_in_temporary_nodes_node_group[0]
