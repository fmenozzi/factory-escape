extends Node2D
class_name Room

onready var _collision_shape: CollisionShape2D = $RoomBoundaries/CollisionShape2D
onready var _camera_anchors: Array = $CameraAnchors.get_children()
onready var _grapple_points: Array = $GrapplePoints.get_children()
onready var _moving_platforms: Array = $MovingPlatforms.get_children()

# Get global positions of all camera anchors in each room. During a transition,
# the player camera will interpolate its position from the closest anchor in
# the old room to the closest anchor in the new room.
func get_camera_anchors() -> Array:
    var anchors = []
    for anchor in _camera_anchors:
        anchors.push_back(anchor.global_position)
    return anchors

func get_closest_camera_anchor(player: Player) -> Vector2:
    var player_pos := player.global_position

    var min_dist := INF
    var min_dist_anchor := Vector2()

    for anchor in self.get_camera_anchors():
        var dist := player_pos.distance_to(anchor)
        if dist < min_dist:
            min_dist = dist
            min_dist_anchor = anchor

    return min_dist_anchor

# Get all the GrapplePoint nodes in the current room.
func get_grapple_points() -> Array:
    var grapple_points = []
    for grapple_point in _grapple_points:
        grapple_points.push_back(grapple_point)
    return grapple_points

func get_room_dimensions() -> Vector2:
    var half_extents = _collision_shape.shape.extents

    return 2 * half_extents

func get_moving_platforms() -> Array:
    return _moving_platforms

func pause() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.pause()
func resume() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.resume()