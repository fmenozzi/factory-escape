extends PhysicsManager
class_name LeapingFailurePhysicsManager

export(float) var horizontal_jump_speed_tiles_per_second := 8.0

export(float) var min_jump_height_tiles := 1.0
export(float) var max_jump_height_tiles := 4.0

export(float) var jump_duration := 0.35

func get_horizontal_jump_speed() -> float:
    return horizontal_jump_speed_tiles_per_second * Util.TILE_SIZE

func get_min_jump_height() -> float:
    return min_jump_height_tiles * Util.TILE_SIZE

func get_max_jump_height() -> float:
    return max_jump_height_tiles * Util.TILE_SIZE

func get_jump_duration() -> float:
    return jump_duration

func get_gravity() -> float:
    return 2 * get_max_jump_height() / pow(get_jump_duration(), 2)

func get_min_jump_velocity() -> float:
    return -sqrt(2 * get_gravity() * get_min_jump_height())

func get_max_jump_velocity() -> float:
    return -sqrt(2 * get_gravity() * get_max_jump_height())
