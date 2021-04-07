extends Node

export(String, 'expand', 'contract') var animation := 'contract'

signal expanded
signal contracted

const WAIT_TIME: float = 0.2

func _ready() -> void:
    assert(not animation.empty())

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play(animation)

func exit(failure: LeapingFailure) -> void:
    pass

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()
    var aggro_manager := failure.get_aggro_manager()

    failure.move(
        Vector2(failure.direction * physics_manager.get_movement_speed(), 10))

    # Switch to next phase in two-phase 'move' cycle once the current animation
    # finishes.
    if not failure.get_animation_player().is_playing():
        match animation:
            'expand':
                return {
                    'new_state': LeapingFailure.State.WAIT,
                    'next_move_state': LeapingFailure.State.CONTRACT,
                    'wait_time': WAIT_TIME,
                }

            'contract':
                return {
                    'new_state': LeapingFailure.State.WAIT,
                    'next_move_state': LeapingFailure.State.EXPAND,
                    'wait_time': WAIT_TIME,
                }

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': LeapingFailure.State.ALERTED}

    if failure.is_on_wall():
        failure.set_direction(-1 * failure.direction)
    elif not failure.is_on_floor():
        return {
            'new_state': LeapingFailure.State.FALL,
            'aggro': false,
        }
    elif failure.is_off_ledge():
        return {
            'new_state': LeapingFailure.State.RETURN_TO_LEDGE,
            'direction_to_ledge': _get_direction_to_ledge(failure),
        }

    return {'new_state': LeapingFailure.State.NO_CHANGE}

func play_expand_sound() -> void:
    emit_signal('expanded')

func play_contract_sound() -> void:
    emit_signal('contracted')

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
