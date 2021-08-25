extends Node2D
class_name HomingProjectile

export(float) var speed_tiles_per_second := 8.0

const MAX_LIFETIME := 20.0

enum State {
    NO_CHANGE,
    SPAWN,
    FOLLOW,
    EXPLODE,
}
var _current_state: Node = null
var _current_state_enum: int = -1

onready var STATES := {
    State.SPAWN:   $States/Spawn,
    State.FOLLOW:  $States/Follow,
    State.EXPLODE: $States/Explode,
}

onready var _trail_particles: Particles2D = $TrailParticles
onready var _hitbox: Area2D = $Hitbox
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
onready var _lifetime_timer: Timer = $LifetimeTimer
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _sound_manager: HomingProjectileSoundManager = $HomingProjectileSoundManager

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
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func start(direction: Vector2) -> void:
    _sound_manager.set_all_muted(false)

    _current_state_enum = State.SPAWN
    _current_state = STATES[_current_state_enum]
    _change_state({
        'new_state': _current_state_enum,
        'direction': direction,
       })

    _lifetime_timer.start()

    resume()

func get_sound_manager() -> HomingProjectileSoundManager:
    return _sound_manager

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_hitbox_collision_shape() -> CollisionShape2D:
    return _hitbox_collision_shape

func get_trail_particles() -> Particles2D:
    return _trail_particles

func pause() -> void:
    set_physics_process(false)
    _sound_manager.set_all_muted(true)

func resume() -> void:
    set_physics_process(true)
    _sound_manager.set_all_muted(false)

    for audio_group in _sound_manager.get_all_audio_groups():
        audio_group.set_state()

func room_reset() -> void:
    queue_free()

func _change_state(new_state_dict: Dictionary) -> void:
    var old_state_enum := _current_state_enum
    var new_state_enum: int = new_state_dict['new_state']

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = old_state_enum

    _current_state.exit(self)
    _current_state_enum = new_state_enum
    _current_state = STATES[new_state_enum]
    _current_state.enter(self, new_state_dict)

func _on_impact(_player_or_environment: Node) -> void:
    _change_state({'new_state': State.EXPLODE})

func _on_lifetime_timeout() -> void:
    _change_state({'new_state': State.EXPLODE})

func _on_projectile_spawner_destroyed() -> void:
    # Destroy the projectile if the spawner (i.e. the enemy spawning it) is
    # destroyed during the projectile's spawn animation.
    if _current_state_enum == State.SPAWN:
        _change_state({'new_state': State.EXPLODE})
