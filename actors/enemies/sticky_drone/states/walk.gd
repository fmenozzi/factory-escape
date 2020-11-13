extends 'res://actors/enemies/enemy_state.gd'

const WALK_DURATION: float = 2.0

onready var _walk_duration_timer: Timer = $WalkDurationTimer

func _ready() -> void:
    _walk_duration_timer.one_shot = true
    _walk_duration_timer.wait_time = WALK_DURATION

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('walk')

    _walk_duration_timer.start()

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()
    var physics_manager := sticky_drone.get_physics_manager()

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': StickyDrone.State.ALERTED}

    if _walk_duration_timer.is_stopped():
        return {'new_state': StickyDrone.State.IDLE}

    if sticky_drone.is_on_wall():
        sticky_drone.set_direction(-1 * sticky_drone.direction)

    if sticky_drone.is_off_ledge():
        return {
            'new_state': StickyDrone.State.RETURN_TO_LEDGE,
            'direction_to_ledge': _get_direction_to_ledge(sticky_drone),
        }

    var velocity := Vector2(
        sticky_drone.direction * physics_manager.get_movement_speed(), 0)

    sticky_drone.move(velocity, Util.NO_SNAP, sticky_drone.get_floor_normal())

    return {'new_state': StickyDrone.State.NO_CHANGE}

func _get_direction_to_ledge(sticky_drone: StickyDrone) -> int:
    var ledge_detectors: Node2D = sticky_drone.get_node('LedgeDetectorRaycasts')
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
