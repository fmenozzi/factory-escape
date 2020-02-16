extends Node2D
class_name GrapplePoint

enum GrappleType {
    # When the player grapples to this point, they are pulled to the grapple
    # point itself.
    NORMAL,

    # When the player grapples to this point, they are launched to another point
    # that is NOT the grapple point itself.
    LAUNCH,
}
export(GrappleType) var grapple_type := GrappleType.NORMAL

var _available: bool = true

onready var _attachment_point: Position2D = $AttachmentPoint
onready var _grapple_range_area: Area2D = $GrappleRangeArea
onready var _no_grapple_area: Area2D = $NoGrappleArea

onready var _launch_point_left: Position2D = $LaunchGrapplePoints/Left
onready var _launch_point_right: Position2D = $LaunchGrapplePoints/Right

onready var _visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D

func _ready() -> void:
    $AnimationPlayer.play('shimmer')

func get_attachment_pos() -> Position2D:
    return _attachment_point

func get_grapple_range_area() -> Area2D:
    return _grapple_range_area

func get_no_grapple_area() -> Area2D:
    return _no_grapple_area

func get_grapple_type() -> int:
    return grapple_type

func get_launch_grapple_points() -> Array:
    return [_launch_point_left, _launch_point_right]

func is_on_screen() -> bool:
    # TODO: This doesn't work sometimes, likely because the granularity of the
    #       grid used for doing these calculations is too small.
    return _visibility_notifier.is_on_screen()

# Grapple points can be marked as unavailable to be excluded from consideration
# during grapple point selection.
func set_available(available: bool) -> void:
    _available = available
func is_available() -> bool:
    return _available
