extends 'res://actors/enemies/enemy_state.gd'

onready var _idle_duration_timer: Timer = $IdleDurationTimer

func _ready() -> void:
    _idle_duration_timer.one_shot = true

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.get_animation_player().play('idle')

    _idle_duration_timer.wait_time = rand_range(0.5, 2.0)
    _idle_duration_timer.start()

func exit(sentry_drone: RangedSentryDrone) -> void:
    pass

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': RangedSentryDrone.State.ALERTED}

    if _idle_duration_timer.is_stopped():
        # Once we finish idling, pick a random point within the room to fly to.
        return {
            'new_state': RangedSentryDrone.State.FLY_TO_POINT,
            'fly_to_point': _get_next_fly_to_point(sentry_drone),
        }

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}

func _get_next_fly_to_point(sentry_drone: RangedSentryDrone) -> Vector2:
    var room: Room = sentry_drone.get_parent().get_parent()
    assert(room != null)

    var room_dims := room.get_room_dimensions()
    var global_room_pos := room.to_global(room.position)

    return Vector2(
        rand_range(global_room_pos.x, global_room_pos.x + room_dims.x),
        rand_range(global_room_pos.y, global_room_pos.y + room_dims.y))
