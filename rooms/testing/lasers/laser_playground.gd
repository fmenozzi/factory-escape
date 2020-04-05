extends Room

onready var _lasers: Array = $Enemies/Lasers.get_children()
onready var _shoot_timer: Timer = $Enemies/ShootTimer

func _ready() -> void:
    _shoot_timer.wait_time = 1.0
    _shoot_timer.connect('timeout', self, '_on_shoot_timeout')
    _shoot_timer.start()

func _on_shoot_timeout() -> void:
    for laser in _lasers:
        laser.shoot()
