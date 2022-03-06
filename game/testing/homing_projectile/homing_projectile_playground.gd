extends RoomFe

onready var _projectile_spawner: Position2D = $ProjectileSpawner
onready var _shoot_timer: Timer = $ShootTimer

func _ready() -> void:
    _shoot_timer.wait_time = 2.0
    _shoot_timer.connect('timeout', self, 'shoot')
    _shoot_timer.start()

    shoot()

func shoot() -> void:
    _projectile_spawner.shoot_homing_projectile(Vector2.RIGHT)
