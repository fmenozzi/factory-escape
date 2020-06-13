extends PhysicsManager
class_name GroundedPhysicsManager

# The min/max jump heights the actor can achieve in pixels. For the player,
# releasing the jump button early will "cut" the jump somewhere between these
# two values, allowing for variable-height jumps.
export(float) var min_jump_height_tiles := 0.5
export(float) var max_jump_height_tiles := 3.5

# The duration of the max-height jump in seconds from ground to peak.
export(float) var jump_duration := 0.4

func get_min_jump_height() -> float:
    return min_jump_height_tiles * Util.TILE_SIZE

func get_max_jump_height() -> float:
    return max_jump_height_tiles * Util.TILE_SIZE

func get_jump_duration() -> float:
    return jump_duration

# The downward speed applied to the actor when falling, measured in pixels per
# second. This is calculated using basic kinematics with max jump height and
# jump duration.
func get_gravity() -> float:
    return 2 * get_max_jump_height() / pow(get_jump_duration(), 2)

# The minimum and maximum y-axis velocities achievable by the actor when
# jumping. The default jump velocity is max jump velocity, but the player can
# release the jump button during a jump, causing the velocity to "cut" and be
# reduced to min jump velocity, allowing for variable-height jumps.
func get_min_jump_velocity() -> float:
    return -sqrt(2 * get_gravity() * get_min_jump_height())
func get_max_jump_velocity() -> float:
    return -sqrt(2 * get_gravity() * get_max_jump_height())
