extends Node2D

export(float) var speed_tiles_per_second := 8.0

const MAX_LIFETIME := 20.0

var _velocity := Vector2.ZERO

onready var _trail_particles: Particles2D = $TrailParticles
onready var _hitbox: Area2D = $Hitbox
onready var _lifetime_timer: Timer = $LifetimeTimer
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    set_physics_process(false)

    _hitbox.connect('body_entered', self, '_on_impact')

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
    _lifetime_timer.start()
    set_physics_process(true)

func _explode() -> void:
    # Stop moving the projectile.
    set_physics_process(false)

    # Wait for explode animation to finish.
    _animation_player.play('explode')
    yield(_animation_player, 'animation_finished')

    # Wait for the trail particles to disappear, since they last a few seconds.
    yield(get_tree().create_timer(_trail_particles.lifetime), 'timeout')

    queue_free()

func _on_impact(body: Node) -> void:
    _explode()

func _on_lifetime_timeout() -> void:
    _explode()
