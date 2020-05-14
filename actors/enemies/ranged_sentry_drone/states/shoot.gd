extends 'res://actors/enemies/state.gd'

var _player: Player = null

onready var _shoot_timer: Timer = $ShootTimer

func _ready() -> void:
    _shoot_timer.one_shot = false
    _shoot_timer.wait_time = 2.0

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # Pause current animation.
    sentry_drone.get_animation_player().stop(false)

    # Turn to face player when shooting.
    sentry_drone.set_direction(Util.direction(sentry_drone, _player))

    # Start shoot timer.
    _shoot_timer.connect('timeout', self, '_shoot', [sentry_drone])
    _shoot_timer.start()
    _shoot(sentry_drone)

func exit(sentry_drone: RangedSentryDrone) -> void:
    _shoot_timer.stop()

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_aggro_range() or aggro_manager.can_see_player()):
        return {'new_state': RangedSentryDrone.State.UNALERTED}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}

func _shoot(sentry_drone: RangedSentryDrone) -> void:
    var dir = sentry_drone.global_position.direction_to(_player.global_position)
    sentry_drone.get_projectile_spawner().shoot(dir)
