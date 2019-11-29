tool
extends Node

signal flashing_finished

const flash_shader := preload('res://shaders/flash.shader')

export(NodePath) var sprite_path = ""
export(float) var total_duration := 2.0
export(float) var single_flash_duration := 0.075
export(Color) var flash_color := Color.white

onready var _sprite: Sprite = null
onready var _timer: Timer = $Timer
onready var _tween: Tween = $Tween

func _get_configuration_warning() -> String:
    if sprite_path == "":
        return "Please specify the sprite to flash."
    return ""

func _ready() -> void:
    # Setup flash duration timer.
    _timer.one_shot = true
    _timer.wait_time = total_duration
    _timer.connect('timeout', self, '_on_flashing_timeout')

    # Get the sprite to flash.
    assert(sprite_path != "")
    _sprite = get_node(sprite_path)

func start_flashing() -> void:
    _setup_tween()

    _timer.start()
    _tween.resume_all()
func stop_flashing() -> void:
    _tween.reset_all()
    _tween.stop_all()

func pause_timer() -> void:
    _timer.paused = true
func resume_timer() -> void:
    _timer.paused = false

func _setup_tween() -> void:
    # Attach flash shader to sprite and set flash color shader param.
    var shader_material := ShaderMaterial.new()
    shader_material.set_shader(flash_shader)
    shader_material.set_shader_param('flash_color', flash_color)
    _sprite.set_material(shader_material)

    # Reset flash tween to animate lerp amount in flash shader.
    var material := _sprite.get_material()
    var param := 'shader_param/lerp_amount'
    var old := 0.0
    var new := 1.0
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN
    var delay := single_flash_duration
    _tween.remove_all()
    _tween.interpolate_property(
        material, param, old, new, single_flash_duration, trans, easing)
    _tween.interpolate_property(
        material, param, new, old, single_flash_duration, trans, easing, delay)

func _on_flashing_timeout() -> void:
    stop_flashing()

    # Remove shader from sprite. This is primarily to allow for other shaders to
    # be used on the sprite afterwards if necessary.
    _sprite.set_material(null)

    emit_signal('flashing_finished')