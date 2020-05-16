extends 'res://actors/enemies/state.gd'

var _player: Player

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    sentry_drone.get_animation_player().play('idle')

func exit(sentry_drone: RangedSentryDrone) -> void:
    pass

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()
    var physics_manager := sentry_drone.get_physics_manager()

    # Move toward player.
    var dir := sentry_drone.global_position.direction_to(_player.get_center())
    sentry_drone.set_direction(Util.direction(sentry_drone, _player))
    sentry_drone.move(dir.normalized() * physics_manager.get_movement_speed())

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_aggro_range() or aggro_manager.can_see_player()):
        return {'new_state': RangedSentryDrone.State.UNALERTED}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
