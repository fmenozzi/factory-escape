extends Node2D
class_name LaserEmitter

onready var _laser: Laser = $Laser

func get_laser() -> Laser:
    return _laser

func shoot() -> void:
    _laser.shoot()

func pause() -> void:
    _laser.pause()
    _laser.lamp_reset()

func resume() -> void:
    _laser.resume()

func show_visuals() -> void:
    _laser.show_visuals()

func hide_visuals() -> void:
    _laser.hide_visuals()
