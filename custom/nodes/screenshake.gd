extends Node

signal started_shaking
signal stopped_shaking

enum Priority {
    LOW,
    HIGH,
}

const DURATION_SHORT := 0.1
const DURATION_MEDIUM := 0.5
const DURATION_LONG := 1.0

const FREQ := 20.0

const AMPLITUDE_SMALL := 0.25 * Util.TILE_SIZE
const AMPLITUDE_MEDIUM := 1.0 * Util.TILE_SIZE
const AMPLITUDE_LARGE := 2.0 * Util.TILE_SIZE

export(float, EASE) var damp_easing := 1.0

var _amplitude: float
var _priority: int = Priority.LOW

onready var _offset_tween: Tween = $OffsetTween
onready var _shake_frequency_timer: Timer = $FrequencyTimer
onready var _shake_duration_timer: Timer = $DurationTimer
onready var _camera: Camera2D

func _ready() -> void:
    _shake_frequency_timer.connect('timeout', self, '_on_frequency_timeout')
    _shake_duration_timer.connect('timeout', self, '_on_duration_timeout')

func shake(
    duration: float,
    frequency: float,
    amplitude: float,
    priority: int = Priority.LOW
) -> void:
    if priority < _priority:
        return

    _camera = Util.get_player().get_camera()

    _amplitude = amplitude

    _shake_duration_timer.wait_time = duration
    _shake_frequency_timer.wait_time = 1.0 / frequency

    _shake_duration_timer.start()
    _shake_frequency_timer.start()

    _shake_once()

    emit_signal('started_shaking')

func stop() -> void:
    _reset_camera_offset()
    _shake_frequency_timer.stop()

    _priority = Priority.LOW

    emit_signal('stopped_shaking')

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
    stop()
