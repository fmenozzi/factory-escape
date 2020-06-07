extends Node2D
class_name Turret

onready var _head: Node2D = $Head
onready var _projectile_spawner: ProjectileSpawner = $Head/ProjectileSpawner

func rotate_head(angle: float) -> void:
    _head.rotation += angle

func shoot() -> void:
    var direction := Vector2.RIGHT.rotated(_head.rotation)
    _projectile_spawner.shoot_energy_projectile(direction)
