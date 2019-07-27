extends Node2D
class_name GrapplePoint

func _ready() -> void:
    $AnimationPlayer.play('shimmer')

func get_attachment_pos() -> Vector2:
    return $AttachmentPoint.global_position

func get_grapple_range_area() -> Area2D:
    return $GrappleRangeArea as Area2D