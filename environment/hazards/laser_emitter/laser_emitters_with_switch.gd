extends Node2D

onready var _laser_emitters: Array = $LaserEmitters.get_children()
onready var _switch: Switch = $Switch
onready var _timer: Timer = $ShootTimer

var _is_active := true

func _ready() -> void:
    assert(not _laser_emitters.empty())
    for laser_emitter in _laser_emitters:
        assert(laser_emitter is LaserEmitter)

    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

    _timer.one_shot = false
    _timer.wait_time = 4.0
    _timer.connect('timeout', self, '_shoot')

func pause() -> void:
    _timer.stop()

    for laser_emitter in _laser_emitters:
        laser_emitter.pause()

func resume() -> void:
    if not _is_active:
        return

    _timer.start()

    for laser_emitter in _laser_emitters:
        laser_emitter.resume()

    _shoot()

func _shoot() -> void:
    for laser_emitter in _laser_emitters:
        laser_emitter.shoot()

func _on_switch_pressed() -> void:
    _is_active = false

    _timer.stop()
    _timer.disconnect('timeout', self, '_shoot')
