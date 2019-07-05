extends Node2D
class_name Room

# Determines how the camera will behave in each room.
#
# TODO: Do we still need this?
enum CameraBehavior {
    # For small rooms that fit entirely within the viewport. When the player
    # enters a ROOM_FIXED room, the camera will be fixed to the center of the
    # viewport (i.e. the center of the room).
    ROOM_FIXED,

    # For rooms whose width fits within the viewport. When the player enters a
    # ROOM_FIXED_VERTICAL room, the camera will follow the player up and down
    # but there will be no camera motion left and right.
    ROOM_FIXED_VERTICAL,

    # For rooms whose height fits within the viewport. When the player enters a
    # ROOM_FIXED_HORIZONTAL room, the camera will follow the player left and
    # right but there will be no camera motion up and down.
    ROOM_FIXED_HORIZONTAL,

    # For large rooms that do not fit entirely within the viewport. When the
    # player enters a PLAYER_FIXED room, the camera will be centered on the
    # player and will follow them around accordingly.
    PLAYER_FIXED,
}
export(CameraBehavior) var camera_behavior := CameraBehavior.ROOM_FIXED

# TODO: Do we still need this?
func setup_room(room_boundaries: Area2D) -> void:
    pass

# Get global positions of all camera anchors in each room. During a transition,
# the player camera will interpolate its position from the closest anchor in
# the old room to the closest anchor in the new room.
func get_camera_anchors() -> Array:
    var anchors = []
    for anchor in get_node('CameraAnchors').get_children():
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

# TODO: don't rely on inherited node strucutres for getting Area2D.
func get_room_dimensions() -> Vector2:
    var half_extents = get_node('RoomBoundaries').get_node('CollisionShape2D').shape.extents

    return 2 * half_extents