extends 'res://actors/enemies/enemy_state.gd'

onready var _shoot_timer: Timer = $ShootTimer

var _player: Player
var _velocity := Vector2.ZERO

func _ready() -> void:
    _shoot_timer.one_shot = true

func enter(sentry_drone: RangedSentryDrone, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()

    # The initial velocity is toward the player's general direction.
    _velocity = sentry_drone.global_position.direction_to(_player.get_center())
    _velocity = _velocity.rotated(rand_range(-PI/8.0, PI/8.0))

    sentry_drone.get_animation_player().play('idle')

    # Wait 1-2 seconds before shooting.
    _shoot_timer.wait_time = rand_range(1.0, 2.0)
    _shoot_timer.start()

func exit(sentry_drone: RangedSentryDrone) -> void:
    _shoot_timer.stop()

func update(sentry_drone: RangedSentryDrone, delta: float) -> Dictionary:
    var aggro_manager := sentry_drone.get_aggro_manager()

    # Move toward player.
    _update_velocity(sentry_drone)
    sentry_drone.set_direction(Util.direction(sentry_drone, _player))
    sentry_drone.move(_velocity)

    # Transition to unalerted state once outside of aggro radius or once the
    # player is no longer visible.
    if not (aggro_manager.in_unaggro_range() and aggro_manager.can_see_player()):
        return {'new_state': RangedSentryDrone.State.UNALERTED}

    if _shoot_timer.is_stopped():
        return {'new_state': RangedSentryDrone.State.SHOOT}

    return {'new_state': RangedSentryDrone.State.NO_CHANGE}

func _update_velocity(sentry_drone: RangedSentryDrone) -> void:
    var physics_manager := sentry_drone.get_physics_manager()

    # Similar to the homing projectile, home in slightly towards the player.
    # Unlike the homing projectile, the homing weight is fixed, as we always
    # want to be moving toward the player during this state.
    var current_dir := _velocity.normalized()
    var player_dir := sentry_drone.global_position.direction_to(_player.get_center()).normalized()
    var final_dir: Vector2 = lerp(current_dir, player_dir, 0.1).normalized()

    # Update the velocity to point in the new direction.
    _velocity += (final_dir * physics_manager.get_movement_speed() - _velocity)
