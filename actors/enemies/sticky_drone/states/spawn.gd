extends 'res://actors/enemies/enemy_state.gd'

onready var _arena_spawner: ArenaSpawner = $ArenaSpawner

var _spawn_finished := false

func _ready() -> void:
    _arena_spawner.connect('spawn_finished', self, '_on_spawn_finished')

func enter(sticky_drone: StickyDrone, previous_state_dict: Dictionary) -> void:
    sticky_drone.set_hit_and_hurt_boxes_disabled(true)
    sticky_drone.get_animation_player().play('spawn')

    _spawn_finished = false
    _arena_spawner.activate_spawn_shader(sticky_drone.get_spawn_shader_sprite())

func exit(sticky_drone: StickyDrone) -> void:
    sticky_drone.set_hit_and_hurt_boxes_disabled(false)

func update(sticky_drone: StickyDrone, delta: float) -> Dictionary:
    if _spawn_finished:
        return {'new_state': sticky_drone.initial_state}

    return {'new_state': StickyDrone.State.NO_CHANGE}

func _on_spawn_finished() -> void:
    _spawn_finished = true
