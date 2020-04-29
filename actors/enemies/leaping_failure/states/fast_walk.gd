extends 'res://actors/enemies/state.gd'

const SPEED_MULTIPLIER: float = 1.5

onready var _timer: Timer = $FastWalkDurationTimer

var _player: Player = null

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Play standard walk animation but faster.
    failure.get_animation_player().play('walk', -1, SPEED_MULTIPLIER, false)

    # Failure will wait up to one second before jumping again.
    _timer.one_shot = true
    _timer.wait_time = rand_range(0.0, 1.0)
    _timer.start()

    # Face the player.
    failure.set_direction(Util.direction(failure, _player))

func exit(failure: LeapingFailure) -> void:
    _timer.stop()

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    failure.move(
        Vector2(failure.direction * failure.SPEED * SPEED_MULTIPLIER, 10))

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

    if _timer.is_stopped():
        if not failure.is_in_range(_player, failure.UNAGGRO_RADIUS):
            return {'new_state': LeapingFailure.State.UNALERTED}
        else:
            return {'new_state': LeapingFailure.State.TAKEOFF}

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
