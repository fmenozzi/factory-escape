extends Node
class_name PhysicsManager

export(float) var movement_speed_tiles_per_second := 0.0

# The speed at which the actor moves, in pixels per second.
func get_movement_speed() -> float:
    return movement_speed_tiles_per_second * Util.TILE_SIZE

# Max falling speed the actor can achieve in pixels per second.
func get_terminal_velocity() -> float:
    return 20.0 * Util.TILE_SIZE
