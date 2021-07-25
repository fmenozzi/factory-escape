extends Room

func _ready() -> void:
    $ShootTimer.connect('timeout', $Hazards/LaserEmitter, 'shoot')
    $Hazards/LaserEmitter.shoot()
