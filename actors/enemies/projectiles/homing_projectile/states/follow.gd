extends 'res://actors/enemies/enemy_state.gd'

const SPEED_TILES_PER_SECOND := 8.0
const HOMING_DURATION := 0.5

onready var _homing_duration_timer: Timer = $HomingDurationTimer

var _velocity := Vector2.ZERO
var _player: Player

func _ready() -> void:
    _homing_duration_timer.one_shot = true
    _homing_duration_timer.wait_time = HOMING_DURATION
    _homing_duration_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS

func enter(projectile: HomingProjectile, previous_state_dict: Dictionary) -> void:
    assert('direction' in previous_state_dict)
    var direction: Vector2 = previous_state_dict['direction']
    _velocity = direction.normalized() * SPEED_TILES_PER_SECOND * Util.TILE_SIZE

    var sound_manager := projectile.get_sound_manager()
    sound_manager.play(HomingProjectileSoundManager.Sounds.SHOOT)
    sound_manager.play(HomingProjectileSoundManager.Sounds.FOLLOW)

    _player = Util.get_player()

    _homing_duration_timer.start()

func exit(projectile: HomingProjectile) -> void:
    pass

func update(projectile: HomingProjectile, delta: float) -> Dictionary:
    _update_velocity(projectile)
    projectile.position += _velocity * delta

    return {'new_state': HomingProjectile.State.NO_CHANGE}

func _update_velocity(projectile: HomingProjectile) -> void:
    # The homing weight is used to determine how much the projectile will home
    # in towards the player. This is a normalized value, where 0 means the
    # projectile continues in its current direction and 1 means it perfectly
    # follows the player. Values in between will cause the projectile to bend in
    # the general direction of the player.
    var weight := _get_homing_weight()

    # Use the homing weight to determine how much to interpolate the homing
    # projectile's current direction towards the player.
    var current_dir := _velocity.normalized()
    var player_dir := projectile.global_position.direction_to(_player.get_center()).normalized()
    var final_dir: Vector2 = lerp(current_dir, player_dir, weight).normalized()

    # Update the velocity to point in the new direction.
    _velocity += (final_dir * SPEED_TILES_PER_SECOND * Util.TILE_SIZE - _velocity)

func _get_homing_weight() -> float:
    # Get the elapsed time of the homing duration timer as a normalized value
    # from 0 to 1.
    var homing_elapsed_time_fraction := \
        (HOMING_DURATION - _homing_duration_timer.time_left) / HOMING_DURATION

    # The weight starts at 0.25 and decays exponentially over the course of the
    # homing duration. Because exp() is asymptotic, the weight will never reach
    # 0 exactly, which means the projectile will always be bending towards the
    # player ever so slightly. In practice, this looks much more pleasant than
    # interpolating linearly to zero, at which point the projectile would just
    # continue in a straight line.
    return 0.25 * exp(-3.0 * homing_elapsed_time_fraction)
