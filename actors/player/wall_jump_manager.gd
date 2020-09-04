extends Node2D
class_name WallJumpManager

onready var _wall_proximity_detector: Node2D = $WallProximityDetector

# Detects whether the player is close to a wall without necessarily directly
# colliding with it. This is useful for making quick consecutive wall jumps feel
# more comfortable by not requiring the player to connect with the wall for a
# frame before continuing the wall jump chain.
func is_near_wall_front() -> bool:
    return _wall_proximity_detector.is_near_wall_front()
func is_near_wall_back() -> bool:
    return _wall_proximity_detector.is_near_wall_back()

# Gets the wall normal if either set of raycasts is colliding with the wall, or
# Vector2.ZERO otherwise. Useful for ensuring proper player direction when
# performing wall jumps.
func get_wall_normal_front() -> Vector2:
    return _wall_proximity_detector.get_wall_normal_front()
func get_wall_normal_back() -> Vector2:
    return _wall_proximity_detector.get_wall_normal_back()

func get_wall_proximity_detector() -> Node2D:
    return _wall_proximity_detector
