extends Node2D
class_name LaserEmitter

onready var _laser: Laser = $Laser

func shoot() -> void:
    _laser.shoot()

func pause() -> void:
    _laser.pause()
    _laser.lamp_reset()

func resume() -> void:
    _laser.resume()
