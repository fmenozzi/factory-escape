extends Room

func _ready() -> void:
    $ProjectileSpawner.shoot(Vector2.RIGHT)
