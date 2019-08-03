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

func _ready() -> void:
    $AnimationPlayer.play('shimmer')

func get_attachment_pos() -> Vector2:
    return $AttachmentPoint.global_position

func get_grapple_range_area() -> Area2D:
    return $GrappleRangeArea as Area2D

func get_no_grapple_area() -> Area2D:
    return $NoGrappleArea as Area2D

func get_grapple_type() -> int:
    return grapple_type

func get_launch_grapple_points() -> Array:
    return [$LaunchGrapplePoints/Left, $LaunchGrapplePoints/Right]

func is_on_screen() -> bool:
    # TODO: This doesn't work sometimes, likely because the granularity of the
    #       grid used for doing these calculations is too small.
    return $VisibilityNotifier2D.is_on_screen()

# Grapple points can be marked as unavailable to be excluded from consideration
# during grapple point selection.
func set_available(available: bool) -> void:
    _available = available
func is_available() -> bool:
    return _available
