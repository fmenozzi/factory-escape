extends Area2D
#class_name RoomBoundaries

func get_room_dimensions() -> Vector2:
    # Rectangular shape extents are half the dimensions.
    return 2 * $CollisionShape2D.shape.extents