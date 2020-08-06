extends 'res://actors/enemies/enemy_state.gd'

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play('walk')

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    failure.move(
        Vector2(failure.direction * physics_manager.get_movement_speed(), 10))

    if failure.is_on_wall():
        failure.set_direction(-1 * failure.direction)
    elif not failure.is_on_floor():
        return {'new_state': SluggishFailure.State.FALL}
    elif failure.is_off_ledge():
        return {
            'new_state': SluggishFailure.State.RETURN_TO_LEDGE,
            'direction_to_ledge': _get_direction_to_ledge(failure),
        }

    return {'new_state': SluggishFailure.State.NO_CHANGE}

func _get_direction_to_ledge(failure: SluggishFailure) -> int:
    var ledge_detectors: Node2D = failure.get_node('LedgeDetectorRaycasts')
    var ledge_detector_left: RayCast2D = ledge_detectors.get_node('Left')
    var ledge_detector_right: RayCast2D = ledge_detectors.get_node('Right')

    var off_left := not ledge_detector_left.is_colliding()
    var off_right := not ledge_detector_right.is_colliding()
    assert(off_left != off_right)

    if off_left:
        return Util.Direction.RIGHT
    if off_right:
        return Util.Direction.LEFT

    return Util.Direction.NONE
