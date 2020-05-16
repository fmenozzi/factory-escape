extends 'res://actors/enemies/state.gd'

var _global_fly_to_point := Vector2.ZERO
var _nav: Navigation2D
var _path := []

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    assert('fly_to_point' in previous_state_dict)
    _global_fly_to_point = previous_state_dict['fly_to_point']
    assert(_global_fly_to_point != null)

    var room: Room = sentry_drone.get_parent().get_parent()
    assert(room != null)

    _nav = room.get_tilemaps_nav()
    _path = _nav.get_simple_path(
        _nav.to_local(sentry_drone.global_position),
        _nav.to_local(_global_fly_to_point),
        true)

func exit(sentry_drone: RangedSentryDrone) -> void:
    pass

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()
    var physics_manager := sentry_drone.get_physics_manager()
    var speed := physics_manager.get_movement_speed()

    if aggro_manager.in_aggro_range() and aggro_manager.can_see_player():
        return {'new_state': RangedSentryDrone.State.ALERTED}

    # If we can't make a path or we reach our destination, return to idle.
    if _path.empty():
        return {'new_state': RangedSentryDrone.State.IDLE}

    # Move along the nav path, removing each point from the path once we get
    # close to it.
    var dest_local: Vector2 = _path[0]
    var sentry_drone_local_pos := _nav.to_local(sentry_drone.global_position)
    var dist := sentry_drone_local_pos.distance_to(dest_local)
    if dist > 2.0:
        var dir := sentry_drone_local_pos.direction_to(dest_local)
        sentry_drone.set_direction(int(sign(dir.x)))
        sentry_drone.move(speed * dir.normalized())
    else:
        _path.remove(0)

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
