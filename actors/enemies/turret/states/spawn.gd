extends 'res://actors/enemies/enemy_state.gd'

onready var _arena_spawner: ArenaSpawner = $ArenaSpawner

var _spawn_finished := false

func _ready() -> void:
    _arena_spawner.connect('spawn_finished', self, '_on_spawn_finished')

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    turret.set_hit_and_hurt_boxes_disabled(true)

    turret.get_head().visible = false
    turret.get_body().visible = false

    turret.get_spawn_shader_sprite().visible = true

    _spawn_finished = false
    _arena_spawner.activate_spawn_shader(turret.get_spawn_shader_sprite())

func exit(turret: Turret) -> void:
    turret.set_hit_and_hurt_boxes_disabled(false)

    turret.get_head().visible = true
    turret.get_body().visible = true

    turret.get_spawn_shader_sprite().visible = false

func update(turret: Turret, delta: float) -> Dictionary:
    if _spawn_finished:
        return {
            'new_state': turret.initial_state,
            'rotation_direction': -turret.initial_direction,
        }

    return {'new_state': Turret.State.NO_CHANGE}

func _on_spawn_finished() -> void:
    _spawn_finished = true
