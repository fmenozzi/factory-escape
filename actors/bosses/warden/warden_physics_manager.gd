extends GroundedPhysicsManager
class_name WardenPhysicsManager

export(float) var horizontal_jump_speed_tiles_per_second := 8.0

func get_horizontal_jump_speed() -> float:
    return horizontal_jump_speed_tiles_per_second * Util.TILE_SIZE
