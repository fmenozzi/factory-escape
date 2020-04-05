extends Room

onready var _lasers: Array = $Enemies/Lasers.get_children()
onready var _timer: Timer = $Enemies/LaserShotTimer

func _ready() -> void:
    _timer.wait_time = 1.0
    _timer.connect('timeout', self, '_on_shoot_timeout')
    _timer.start()

func _on_shoot_timeout() -> void:
    for laser in _lasers:
        laser.shoot()
