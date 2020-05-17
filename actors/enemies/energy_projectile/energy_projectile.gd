extends Node2D

export(float) var speed_tiles_per_second := 8.0

const MAX_LIFETIME := 20.0
const HOMING_DURATION := 0.5

var _velocity := Vector2.ZERO
var _player: Player

onready var _trail_particles: Particles2D = $TrailParticles
onready var _hitbox: Area2D = $Hitbox
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _lifetime_timer: Timer = $LifetimeTimer
onready var _homing_duration_timer: Timer = $HomingDurationTimer
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    set_physics_process(false)

    # Detect impacts with both the environment (StaticBody2D) and the player's
    # hurtbox (Area2D).
    _hitbox.connect('body_entered', self, '_on_impact')
    _hitbox.connect('area_entered', self, '_on_impact')

    _lifetime_timer.one_shot = true
    _lifetime_timer.wait_time = MAX_LIFETIME
    _lifetime_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
    _lifetime_timer.connect('timeout', self, '_on_lifetime_timeout')

    _homing_duration_timer.one_shot = true
    _homing_duration_timer.wait_time = HOMING_DURATION
    _homing_duration_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS

func _physics_process(delta: float) -> void:
    _update_velocity()
    position += _velocity * delta

func start(direction: Vector2) -> void:
    _animation_player.play('spawn')
    yield(_animation_player, 'animation_finished')

    _velocity = direction.normalized() * speed_tiles_per_second * Util.TILE_SIZE
    _lifetime_timer.start()
    _homing_duration_timer.start()
    _player = Util.get_player()
    set_physics_process(true)

func _update_velocity() -> void:
    # The homing weight is used to determine how much the projectile will home
    # in towards the player. This is a normalized value, where 0 means the
    # projectile continues in its current direction and 1 means it perfectly
    # follows the player. Values in between will cause the projectile to bend in
    # the general direction of the player.
    var weight := _get_homing_weight()

    # Use the homing weight to determine how much to interpolate the homing
    # projectile's current direction towards the player.
    var current_dir := _velocity.normalized()
    var player_dir := global_position.direction_to(_player.get_center()).normalized()
    var final_dir: Vector2 = lerp(current_dir, player_dir, weight).normalized()

    # Update the velocity to point in the new direction.
    _velocity += (final_dir * speed_tiles_per_second * Util.TILE_SIZE - _velocity)

func _get_homing_weight() -> float:
    # Get the elapsed time of the homing duration timer as a normalized value
    # from 0 to 1.
    var homing_elapsed_time_fraction := \
        (HOMING_DURATION - _homing_duration_timer.time_left) / HOMING_DURATION

    # The initial homing weight is itself a linear interpolation; at the start
    # of the shot, the weight is 0.25, and decays linearly over the course of
    # the homing duration to 0, at which point the shot no longer homes in and
    # instead continues in its current direction.
    var weight: float = lerp(0.25, 0.0, homing_elapsed_time_fraction)

    return weight

func _explode() -> void:
    # Stop moving the projectile.
    set_physics_process(false)

    # Disable the projectile's hitbox.
    _hitbox_collision_shape.set_deferred('disabled', true)

    # Wait for explode animation to finish.
    _animation_player.play('explode')
    yield(_animation_player, 'animation_finished')

    # Wait for the trail particles to disappear, since they last a few seconds.
    yield(get_tree().create_timer(_trail_particles.lifetime), 'timeout')

    queue_free()

func _on_impact(_player_or_environment: Node) -> void:
    _explode()

func _on_lifetime_timeout() -> void:
    _explode()
