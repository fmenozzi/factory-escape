extends 'res://actors/enemies/state.gd'

const SHOOT_DURATION := 0.6

var _player: Player = null

onready var _shoot_duration_timer: Timer = $ShootDurationTimer

func _ready() -> void:
    _shoot_duration_timer.one_shot = true
    _shoot_duration_timer.wait_time = SHOOT_DURATION

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    sentry_drone.get_animation_player().stop(false)

    # Turn to face player when shooting.
    sentry_drone.set_direction(Util.direction(sentry_drone, _player))

    # Shoot!
    var dir = sentry_drone.global_position.direction_to(_player.get_center())
    sentry_drone.get_projectile_spawner().shoot(dir)

    # Start shoot duration timer.
    _shoot_duration_timer.start()

func exit(sentry_drone: RangedSentryDrone) -> void:
    pass

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_aggro_range() or aggro_manager.can_see_player()):
        return {'new_state': RangedSentryDrone.State.UNALERTED}

    if _shoot_duration_timer.is_stopped():
        return {'new_state': RangedSentryDrone.State.FOLLOW_PLAYER}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}
