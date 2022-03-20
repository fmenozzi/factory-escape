extends Node2D
class_name ArenaSpawner

signal spawn_finished

const DURATION := 1.0

onready var _tween: Tween = $Tween
onready var _shader_manager: ShaderManager = $ShaderManager

var _time := 0.0

func _ready() -> void:
    set_process(false)

func _process(delta: float) -> void:
    # Rather than use TIME in the shader, we manually pass in time via a uniform
    # so that the glitch effect stops when the game is paused.
    _time += delta
    _shader_manager.set_shader_param('time', _time)

func activate_spawn_shader(sprite: Sprite) -> void:
    _shader_manager.add_shader(Preloads.GlitchShader, sprite)

    set_process(true)

    var mat: ShaderMaterial = _shader_manager.get_shader_material()
    _tween.remove_all()
    _tween.interpolate_property(mat, 'shader_param/shake_power', 0.05, 0.0, DURATION)
    _tween.interpolate_property(mat, 'shader_param/shake_speed', 10.0, 0.0, DURATION)
    _tween.interpolate_property(mat, 'shader_param/shake_block_size', 32.0, 1.0, DURATION)
    _tween.start()
    yield(_tween, 'tween_all_completed')

    set_process(false)
    _time = 0.0

    _shader_manager.clear_shader()

    emit_signal('spawn_finished')
