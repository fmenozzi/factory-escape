extends Node2D
class_name Turret

onready var _head: Node2D = $Head
onready var _head_sprite: Sprite = $Head/Sprite
onready var _projectile_spawner: ProjectileSpawner = $Head/ProjectileSpawner

func rotate_head(angle: float) -> void:
    _head.rotation = fposmod(_head.rotation + angle, 2*PI)
    _head_sprite.flip_v = (PI/2 <= _head.rotation and _head.rotation < 3*PI/2)

func shoot() -> void:
    var direction := Vector2.RIGHT.rotated(_head.rotation)
    _projectile_spawner.shoot_energy_projectile(direction)
