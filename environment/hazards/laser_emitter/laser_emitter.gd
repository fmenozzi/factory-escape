extends Node2D
class_name LaserEmitter

onready var _laser: Laser = $Laser

func shoot() -> void:
    _laser.shoot()

func pause() -> void:
    pass
func resume() -> void:
    pass
