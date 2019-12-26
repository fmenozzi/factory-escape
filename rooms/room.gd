extends Node2D
class_name Room

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

# TODO: Investigate why the collision shape is sometimes null when cached using
#       onready (seems to always only occur in standalone playground rooms).
#       Maybe it has something to do with the fact that Room is a base scene?
func get_room_dimensions() -> Vector2:
    var half_extents = get_node('RoomBoundaries/CollisionShape2D').shape.extents

    return 2 * half_extents

func get_moving_platforms() -> Array:
    return _moving_platforms

func pause() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.pause()
func resume() -> void:
    for moving_platform in get_moving_platforms():
        moving_platform.resume()

func contains(obj: Node2D) -> bool:
    var bounds := Rect2(get_global_position(), get_room_dimensions())

    return bounds.has_point(obj.get_global_position())