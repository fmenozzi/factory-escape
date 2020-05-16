extends 'res://actors/enemies/state.gd'

var _player: Player

onready var _shoot_timer: Timer = $ShootTimer

func _ready() -> void:
    _shoot_timer.one_shot = true

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    sentry_drone.get_animation_player().play('idle')

    # Wait 1-2 seconds before shooting.
    _shoot_timer.wait_time = rand_range(1.0, 2.0)
    _shoot_timer.start()

func exit(sentry_drone: RangedSentryDrone) -> void:
    _shoot_timer.stop()

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

    if _shoot_timer.is_stopped():
        return {'new_state': RangedSentryDrone.State.SHOOT}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
