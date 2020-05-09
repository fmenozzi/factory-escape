extends Room

onready var _projectile_spawner: Position2D = $ProjectileSpawner
onready var _shoot_timer: Timer = $ShootTimer

func _ready() -> void:
    _shoot_timer.wait_time = 1.0
    _shoot_timer.connect('timeout', self, '_on_shoot_timeout')
    _shoot_timer.start()

func _on_shoot_timeout() -> void:
    _projectile_spawner.shoot(Vector2.RIGHT)
