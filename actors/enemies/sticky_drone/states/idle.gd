extends 'res://actors/enemies/state.gd'

const IDLE_DURATION: float = 2.0

onready var _idle_duration_timer: Timer = $IdleDurationTimer

func _ready() -> void:
    _idle_duration_timer.one_shot = true
    _idle_duration_timer.wait_time = IDLE_DURATION

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.get_animation_player().play('idle')

    _idle_duration_timer.start()

func exit(sticky_drone: StickyDrone) -> void:
    pass

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    var aggro_manager := sticky_drone.get_aggro_manager()

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': StickyDrone.State.ALERTED}

    if _idle_duration_timer.is_stopped():
        sticky_drone.set_direction(-1 * sticky_drone.direction)
        return {'new_state': StickyDrone.State.WALK}

    return {'new_state': StickyDrone.State.NO_CHANGE}
