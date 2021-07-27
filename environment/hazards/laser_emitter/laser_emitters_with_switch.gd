extends Node2D

onready var _laser_emitter_group: LaserEmitterGroup = $LaserEmitterGroup
onready var _switch: Switch = $Switch

func _ready() -> void:
    _switch.connect('switch_press_finished', _laser_emitter_group, 'deactivate')

func pause() -> void:
    _laser_emitter_group.pause()

func resume() -> void:
    _laser_emitter_group.resume()
