extends Position2D
class_name ProjectileSpawner

signal projectile_spawner_destroyed
signal homing_projectile_fired(global_pos, direction)

func shoot(direction: Vector2) -> void:
    emit_signal('homing_projectile_fired', global_position, direction)
