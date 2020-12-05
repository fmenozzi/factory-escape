extends Node

signal started_shaking
signal stopped_shaking

enum Priority {
    LOW,
    HIGH,
}

enum Duration {
    VERY_SHORT,
    SHORT,
    MEDIUM,
    LONG,
}

enum Amplitude {
    VERY_SMALL,
    SMALL,
    MEDIUM,
    LARGE,
}

export(float, EASE) var damp_easing := 1.0

var _amplitude: float
var _priority: int = Priority.LOW
var _strength_multiplier := 1.0

onready var _offset_tween: Tween = $OffsetTween
onready var _shake_frequency_timer: Timer = $FrequencyTimer
onready var _shake_duration_timer: Timer = $DurationTimer
onready var _camera: Camera2D

func _ready() -> void:
    _shake_frequency_timer.connect('timeout', self, '_on_frequency_timeout')
    _shake_duration_timer.connect('timeout', self, '_on_duration_timeout')

func start(duration: int, amplitude: int, priority: int = Priority.LOW) -> void:
    if priority < _priority:
        return

    _priority = priority

    _camera = Util.get_player().get_camera()

    _amplitude = _strength_multiplier * _get_amplitude(amplitude)

    _shake_duration_timer.wait_time = _get_duration(duration)
    _shake_frequency_timer.wait_time = 1.0 / 20.0  # 20 Hz frequency

    _shake_duration_timer.start()
    _shake_frequency_timer.start()

    _shake_once()

    emit_signal('started_shaking')

func stop() -> void:
    _reset_camera_offset()
    _shake_frequency_timer.stop()

    _priority = Priority.LOW

    emit_signal('stopped_shaking')

func set_strength_multiplier(strength_multiplier: float) -> void:
    assert(strength_multiplier >= 0)

    _strength_multiplier = strength_multiplier

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

func _get_duration(duration: int) -> float:
    match duration:
        Duration.VERY_SHORT:
            return 0.05

        Duration.SHORT:
            return 0.1

        Duration.MEDIUM:
            return 0.5

        Duration.LONG:
            return 1.0

    return 0.0

func _get_amplitude(amplitude: int) -> float:
    match amplitude:
        Amplitude.VERY_SMALL:
            return 1.0

        Amplitude.SMALL:
            return 0.25 * Util.TILE_SIZE

        Amplitude.MEDIUM:
            return 1.0 * Util.TILE_SIZE

        Amplitude.LARGE:
            return 2.0 * Util.TILE_SIZE

    return 0.0

func _on_frequency_timeout() -> void:
    _shake_once()

func _on_duration_timeout() -> void:
    stop()
