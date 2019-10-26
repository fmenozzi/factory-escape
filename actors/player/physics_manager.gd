extends Node
class_name PhysicsManager

# The speed at which the player can move the character left and right, measured
# in pixels per second.
func get_movement_speed() -> float:
    return 6.0 * Util.TILE_SIZE

# The min/max jump heights the player can achieve in pixels. Releasing the jump
# button early will "cut" the jump somewhere between these two values, allowing
# for variable-height jumps.
func get_min_jump_height() -> float:
    return 0.5 * Util.TILE_SIZE
func get_max_jump_height() -> float:
    return 3.5 * Util.TILE_SIZE

# The duration of the max-height jump in seconds from ground to peak.
func get_jump_duration() -> float:
    return 0.4

# The downward speed applied to the player when falling, measured in pixels per
# second. This is calculated using basic kinematics with max jump height and
# jump duration.
func get_gravity() -> float:
    return 2 * get_max_jump_height() / pow(get_jump_duration(), 2)

# The minimum and maximum y-axis velocities achievable by the player when
# jumping. The default jump velocity is max jump velocity, but if the player
# releases the jump button during a jump, the velocity will "cut" and be reduced
# to min jump velocity. This allows for variable-height jumps.
func get_min_jump_velocity() -> float:
    return -sqrt(2 * get_gravity() * get_min_jump_height())
func get_max_jump_velocity() -> float:
    return -sqrt(2 * get_gravity() * get_max_jump_height())

# Max falling speed the player can achieve in pixels per second.
func get_terminal_velocity() -> float:
    return 20.0 * Util.TILE_SIZE