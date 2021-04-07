extends 'res://actors/enemies/enemy_state.gd'

export(String, 'expand', 'contract') var animation := 'contract'

signal expanded
signal contracted

const WAIT_TIME: float = 0.2

func _ready() -> void:
    assert(not animation.empty())

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    failure.get_animation_player().play(
        animation, -1, failure.speed_multiplier, false)

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    var is_frightened := failure.speed_multiplier > 1.0

    failure.move(
        Vector2(
            failure.direction * failure.speed_multiplier * physics_manager.get_movement_speed(),
            10))

    # Switch to next phase in two-phase 'move' cycle once the current animation
    # finishes.
    if not failure.get_animation_player().is_playing():
        match animation:
            'expand':
                return {
                    'new_state': SluggishFailure.State.WAIT,
                    'next_move_state': SluggishFailure.State.CONTRACT,
                    'wait_time': WAIT_TIME / failure.speed_multiplier,
                }

            'contract':
                return {
                    'new_state': SluggishFailure.State.WAIT,
                    'next_move_state': SluggishFailure.State.EXPAND,
                    'wait_time': WAIT_TIME / failure.speed_multiplier,
                }

    if failure.is_on_wall():
        if not is_frightened:
            failure.set_direction(-1 * failure.direction)
    elif not failure.is_on_floor():
        return {'new_state': SluggishFailure.State.FALL}
    elif failure.is_off_ledge():
        if not is_frightened:
            return {
                'new_state': SluggishFailure.State.RETURN_TO_LEDGE,
                'direction_to_ledge': _get_direction_to_ledge(failure),
            }

    return {'new_state': SluggishFailure.State.NO_CHANGE}

func play_expand_sound() -> void:
    emit_signal('expanded')

func play_contract_sound() -> void:
    emit_signal('contracted')

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
