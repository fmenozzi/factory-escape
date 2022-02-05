extends 'res://actors/enemies/enemy_state.gd'

onready var _arena_spawner: ArenaSpawner = $ArenaSpawner

var _spawn_finished := false

func _ready() -> void:
    _arena_spawner.connect('spawn_finished', self, '_on_spawn_finished')

func enter(sentry_drone: SentryDrone, previous_state_dict: Dictionary) -> void:
    sentry_drone.set_hit_and_hurt_boxes_disabled(true)
    sentry_drone.get_animation_player().play('spawn')

    _spawn_finished = false
    _arena_spawner.activate_spawn_shader(sentry_drone.get_spawn_shader_sprite())

func exit(sentry_drone: SentryDrone) -> void:
    sentry_drone.set_hit_and_hurt_boxes_disabled(false)

func update(sentry_drone: SentryDrone, delta: float) -> Dictionary:
    if _spawn_finished:
        return {'new_state': sentry_drone.initial_state}

    return {'new_state': SentryDrone.State.NO_CHANGE}

func _on_spawn_finished() -> void:
    _spawn_finished = true
