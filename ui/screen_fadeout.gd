extends Control

signal fade_to_black_finished
signal fade_from_black_finished

const TRANSPARENT_ALPHA := 0.0
const OPAQUE_ALPHA := 1.0

onready var _black_overlay: ColorRect = $BlackOverlay
onready var _fade_tween: Tween = $FadeTween

func fade_to_black(duration: float, delay: float = 0.0) -> void:
    _fade(TRANSPARENT_ALPHA, OPAQUE_ALPHA, duration, delay)
    yield(_fade_tween, 'tween_all_completed')

    emit_signal('fade_to_black_finished')

func fade_from_black(duration: float, delay: float = 0.0) -> void:
    _fade(OPAQUE_ALPHA, TRANSPARENT_ALPHA, duration, delay)
    yield(_fade_tween, 'tween_all_completed')

    emit_signal('fade_from_black_finished')

func _fade(old: float, new: float, duration: float, delay: float) -> void:
    _fade_tween.remove_all()
    _fade_tween.interpolate_property(
        _black_overlay, 'modulate:a', old, new, duration, Tween.TRANS_LINEAR,
        Tween.EASE_IN, delay)
    _fade_tween.start()
