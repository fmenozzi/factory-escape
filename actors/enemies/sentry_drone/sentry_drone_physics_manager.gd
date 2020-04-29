extends PhysicsManager
class_name SentryDronePhysicsManager

export(float) var bash_speed_tiles_per_second := 16.0

func get_bash_speed() -> float:
    return bash_speed_tiles_per_second * Util.TILE_SIZE
