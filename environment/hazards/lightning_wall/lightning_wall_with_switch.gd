extends Node2D

onready var _lightning_wall: LightningWall = $LightningWall
onready var _switch: Switch = $Switch

func _ready() -> void:
    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func pause() -> void:
    _lightning_wall.pause()

func resume() -> void:
    _lightning_wall.resume()

func _on_switch_pressed() -> void:
    _lightning_wall.dissipate()
