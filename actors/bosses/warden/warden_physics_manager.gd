extends GroundedPhysicsManager
class_name WardenPhysicsManager

export(float) var horizontal_jump_speed_tiles_per_second := 8.0
export(float) var horizontal_backstep_speed_tiles_per_second := 8.0
export(float) var max_backstep_height_tiles := 3.5
export(float) var backstep_duration := 0.2
export(float) var run_speed_tiles_per_second := 6.0

func get_horizontal_jump_speed() -> float:
    return horizontal_jump_speed_tiles_per_second * Util.TILE_SIZE

func get_horizontal_backstep_speed() -> float:
    return horizontal_backstep_speed_tiles_per_second * Util.TILE_SIZE

func get_max_backstep_height() -> float:
    return max_backstep_height_tiles * Util.TILE_SIZE

func get_backstep_duration() -> float:
    return backstep_duration

func get_backstep_gravity() -> float:
    return 2 * get_max_backstep_height() / pow(get_backstep_duration(), 2)

func get_max_backstep_velocity() -> float:
    return -sqrt(2 * get_backstep_gravity() * get_max_backstep_height())

func get_run_speed() -> float:
    return run_speed_tiles_per_second * Util.TILE_SIZE
