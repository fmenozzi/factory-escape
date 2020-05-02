extends 'res://actors/enemies/state.gd'

var _player: Player = null

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play('walk')

    _player = Util.get_player()

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()
    var aggro_manager := failure.get_aggro_manager()

    failure.move(
        Vector2(failure.direction * physics_manager.get_movement_speed(), 10))

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': LeapingFailure.State.ALERTED}

    if failure.is_on_wall():
        failure.set_direction(-1 * failure.direction)
    elif not failure.is_on_floor():
        return {'new_state': LeapingFailure.State.FALL}
    elif failure.is_off_ledge():
        return {
            'new_state': LeapingFailure.State.RETURN_TO_LEDGE,
            'direction_to_ledge': _get_direction_to_ledge(failure),
        }

    return {'new_state': LeapingFailure.State.NO_CHANGE}

func _get_direction_to_ledge(failure: LeapingFailure) -> int:
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
