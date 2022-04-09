extends Node2D

onready var _laser_emitter_group: LaserEmitterGroup = $LaserEmitterGroup
onready var _switch: Switch = $Switch
onready var _save_manager: LaserEmittersWithSwitchSaveManager = $SaveManager

func _ready() -> void:
    _switch.connect('switch_press_finished', self, '_on_switch_pressed')

func pause() -> void:
    _laser_emitter_group.pause()

func resume() -> void:
    _laser_emitter_group.resume()

func show_visuals() -> void:
    _laser_emitter_group.show_visuals()

func hide_visuals() -> void:
    _laser_emitter_group.hide_visuals()

func _on_switch_pressed() -> void:
    _laser_emitter_group.deactivate()
    _save_manager.is_active = false
