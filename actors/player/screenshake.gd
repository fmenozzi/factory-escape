tool
extends Node2D

const SHAKE_DURATION_SHORT := 0.1
const SHAKE_DURATION_MEDIUM := 0.5
const SHAKE_DURATION_LONG := 1.0

const SHAKE_FREQ := 20.0

const SHAKE_AMPL_SMALL := 0.25 * Util.TILE_SIZE
const SHAKE_AMPL_MEDIUM := 1.0 * Util.TILE_SIZE
const SHAKE_AMPL_LARGE := 2.0 * Util.TILE_SIZE

export(float, EASE) var damp_easing := 1.0

export(NodePath) var camera_path := NodePath('')
var _camera: Camera2D = null

var _amplitude: float

onready var _offset_tween: Tween = $OffsetTween
onready var _shake_frequency_timer: Timer = $FrequencyTimer
onready var _shake_duration_timer: Timer = $DurationTimer

func _get_configuration_warning() -> String:
    if camera_path.is_empty():
        return 'Must provide path to Camera2D to shake!'

    return ''

func _ready() -> void:
    _camera = get_node(camera_path)

    _shake_frequency_timer.connect('timeout', self, '_on_frequency_timeout')
    _shake_duration_timer.connect('timeout', self, '_on_duration_timeout')

func shake(duration: float, freq: float, amplitude: float) -> void:
    _amplitude = amplitude

    _shake_duration_timer.wait_time = duration
    _shake_frequency_timer.wait_time = 1.0 / freq

    _shake_duration_timer.start()
    _shake_frequency_timer.start()

    _shake_once()

func _shake_once() -> void:
    var damping := ease(
        _shake_duration_timer.time_left / _shake_duration_timer.wait_time,
        damp_easing)

    var rand := Vector2(
        damping * rand_range(-_amplitude, _amplitude),
        damping * rand_range(-_amplitude, _amplitude))

    _offset_tween.interpolate_property(
        _camera, 'offset', _camera.offset, rand,
        _shake_frequency_timer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    _offset_tween.start()

func _reset_camera_offset() -> void:
    # Tween back to an offset of (0, 0)
    _offset_tween.interpolate_property(
        _camera, 'offset', _camera.offset, Vector2.ZERO,
        _shake_frequency_timer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    _offset_tween.start()

func _on_frequency_timeout() -> void:
    _shake_once()

func _on_duration_timeout() -> void:
    _reset_camera_offset()
    _shake_frequency_timer.stop()
