extends Position2D

signal energy_projectile_fired(global_pos, direction)

func shoot(direction: Vector2) -> void:
    emit_signal('energy_projectile_fired', global_position, direction)
