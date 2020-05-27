extends 'res://actors/enemies/state.gd'

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

    var velocity := Vector2(
        sticky_drone.direction * physics_manager.get_movement_speed(), 0)

    sticky_drone.move(velocity, Util.NO_SNAP, sticky_drone.get_floor_normal())

    return {'new_state': StickyDrone.State.NO_CHANGE}
