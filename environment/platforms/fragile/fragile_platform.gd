extends Node2D
class_name FragilePlatform

onready var _dust_puff_spawn_positions: Array = $DustPuffSpawnPositions.get_children()
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    for position2d in _dust_puff_spawn_positions:
        assert(position2d is Position2D)

func break() -> void:
    _animation_player.play('break')

func reset() -> void:
    _animation_player.seek(0, true)

func _spawn_dust_puffs() -> void:
    for dust_puff_spawn_position in _dust_puff_spawn_positions:
        Effects.spawn_dust_puff_at(self.to_global(dust_puff_spawn_position.position))
