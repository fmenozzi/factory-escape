extends Room

const EnergyProjectile := preload('res://actors/enemies/energy_projectile/EnergyProjectile.tscn')

func _ready() -> void:
    spawn_projectile(Vector2(32, 128), Vector2.RIGHT)

func spawn_projectile(pos: Vector2, dir: Vector2) -> void:
    var energy_projectile := EnergyProjectile.instance()
    energy_projectile.position = pos

    $Enemies.add_child(energy_projectile)

    energy_projectile.start(dir)
