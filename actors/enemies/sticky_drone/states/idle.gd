extends 'res://actors/enemies/enemy_state.gd'

# The minimum number of seconds the drone waits while idling before turning
# around. A small random value will be added to this to create the final timer
# duration in order to avoid having all the drones turn around at the same time.
const MIN_IDLE_DURATION: float = 2.0

onready var _idle_duration_timer: Timer = $IdleDurationTimer

func _ready() -> void:
    _idle_duration_timer.one_shot = true
    _idle_duration_timer.wait_time = MIN_IDLE_DURATION + rand_range(0.0, 1.0)

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
