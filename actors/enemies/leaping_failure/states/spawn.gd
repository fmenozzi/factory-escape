extends 'res://actors/enemies/enemy_state.gd'

onready var _arena_spawner: ArenaSpawner = $ArenaSpawner

var _spawn_finished := false

func _ready() -> void:
    _arena_spawner.connect('spawn_finished', self, '_on_spawn_finished')

func enter(failure: LeapingFailure, previous_state_dict: Dictionary) -> void:
    failure.set_hit_and_hurt_boxes_disabled(true)
    failure.get_animation_player().play('spawn')

    _spawn_finished = false
    _arena_spawner.activate_spawn_shader(failure.get_spawn_shader_sprite())

func exit(failure: LeapingFailure) -> void:
    failure.set_hit_and_hurt_boxes_disabled(false)

func update(failure: LeapingFailure, delta: float) -> Dictionary:
    if _spawn_finished:
        return {'new_state': failure.initial_state}

    return {'new_state': LeapingFailure.State.NO_CHANGE}

func _on_spawn_finished() -> void:
    _spawn_finished = true
