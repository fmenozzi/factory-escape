extends Room

const ROTATION_SPEED := PI/8.0

var _angle := 0.0

onready var _shoot_timer: Timer = $ShootTimer

func _ready() -> void:
    _shoot_timer.one_shot = false
    _shoot_timer.wait_time = 1.0
    _shoot_timer.connect('timeout', self, '_shoot')
    _shoot_timer.start()

    _shoot()

func _process(delta: float) -> void:
    for enemy in $Enemies.get_children():
        if enemy is Turret:
            enemy.rotate_head(ROTATION_SPEED * delta)

func _shoot() -> void:
    for enemy in $Enemies.get_children():
        if enemy is Turret:
            enemy.shoot()
