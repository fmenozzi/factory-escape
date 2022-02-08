extends Position2D
class_name ProjectileSpawner

signal projectile_spawner_destroyed
signal homing_projectile_fired(global_pos, direction, sector_five)
signal energy_projectile_fired(global_pos, direction, sector_five)

export(bool) var sector_five := false

func shoot_homing_projectile(direction: Vector2) -> void:
    emit_signal('homing_projectile_fired', global_position, direction, sector_five)

func shoot_energy_projectile(direction: Vector2) -> void:
    emit_signal('energy_projectile_fired', global_position, direction, sector_five)
