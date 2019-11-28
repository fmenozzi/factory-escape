extends 'res://actors/enemies/state.gd'

func enter(slime: Slime, previous_state_dict: Dictionary) -> void:
    slime.get_node('AnimationPlayer').play('walk')

func exit(slime: Slime) -> void:
    pass

func update(slime: Slime, delta: float) -> Dictionary:
    slime.move(Vector2(slime.direction * slime.SPEED, 10))

    if slime.is_on_wall():
        slime.set_direction(-1 * slime.direction)
    elif not slime.is_on_floor():
        return {'new_state': Slime.State.FALL}
    elif slime.is_off_ledge():
        return {
            'new_state': Slime.State.RETURN_TO_LEDGE,
            'direction_to_ledge': _get_direction_to_ledge(slime),
        }

    return {'new_state': Slime.State.NO_CHANGE}

func _get_direction_to_ledge(slime: Slime) -> int:
    var ledge_detectors: Node2D = slime.get_node('LedgeDetectorRaycasts')
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