extends Node2D
class_name WallJumpManager

const SAVE_KEY := 'wall_jump_manager'

var _has_wall_jump := false

onready var _wall_proximity_detector: Node2D = $WallProximityDetector

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'has_wall_jump': _has_wall_jump,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var wall_jump_manager_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('has_wall_jump' in wall_jump_manager_save_data)

    _has_wall_jump = wall_jump_manager_save_data['has_wall_jump']

func can_wall_jump() -> bool:
    return _has_wall_jump

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
