extends Node2D
class_name EnergyProjectile

export(float) var speed_tiles_per_second := 16.0

const MAX_LIFETIME := 20.0

var _velocity := Vector2.ZERO

onready var _trail_particles: Particles2D = $TrailParticles
onready var _hitbox: Area2D = $Hitbox
onready var _lifetime_timer: Timer = $LifetimeTimer
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _shoot_audio_stream_player: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/Shoot
onready var _impact_audio_stream_player: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/Impact

func _ready() -> void:
    pause()

    # Detect impacts with both the environment (StaticBody2D) and the player's
    # hurtbox (Area2D).
    _hitbox.connect('body_entered', self, '_on_impact')
    _hitbox.connect('area_entered', self, '_on_impact')

    _lifetime_timer.one_shot = true
    _lifetime_timer.wait_time = MAX_LIFETIME
    _lifetime_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
    _lifetime_timer.connect('timeout', self, '_on_lifetime_timeout')

func _physics_process(delta: float) -> void:
    position += _velocity * delta

func start(direction: Vector2) -> void:
    _animation_player.play('spawn')
    yield(_animation_player, 'animation_finished')

    _velocity = direction.normalized() * speed_tiles_per_second * Util.TILE_SIZE
    self.rotation = direction.angle()
    _lifetime_timer.start()

    resume()

    _shoot_audio_stream_player.play()

func pause() -> void:
    set_physics_process(false)

func resume() -> void:
    set_physics_process(true)

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass

func room_reset() -> void:
    queue_free()

func _impact() -> void:
    # Stop moving the projectile.
    set_physics_process(false)

    _impact_audio_stream_player.play()

    # Wait for impact animation to finish.
    _animation_player.play('impact')
    yield(_animation_player, 'animation_finished')

    # Wait for the trail particles to disappear.
    yield(get_tree().create_timer(_trail_particles.lifetime), 'timeout')

    queue_free()

func _on_impact(_player_or_environment: Node) -> void:
    _impact()

func _on_lifetime_timeout() -> void:
    _impact()

func _on_projectile_spawner_destroyed() -> void:
    # Destroy the projectile if the spawner (i.e. the enemy spawning it) is
    # destroyed during the projectile's spawn animation.
    if _animation_player.is_playing() and _animation_player.current_animation == 'spawn':
        _impact()
