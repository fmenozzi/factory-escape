extends Control

signal fade_to_black_finished
signal fade_from_black_finished

const TRANSPARENT_ALPHA := 0.0
const OPAQUE_ALPHA := 1.0

onready var _black_overlay: ColorRect = $BlackOverlay
onready var _fade_tween: Tween = $FadeTween

func fade_to_black(duration: float, delay: float = 0.0, fade_music: bool = true) -> void:
    _fade(TRANSPARENT_ALPHA, OPAQUE_ALPHA, duration, delay, fade_music)
    yield(_fade_tween, 'tween_all_completed')

    emit_signal('fade_to_black_finished')

func fade_from_black(duration: float, delay: float = 0.0, fade_music: bool = true) -> void:
    _fade(OPAQUE_ALPHA, TRANSPARENT_ALPHA, duration, delay, fade_music)
    yield(_fade_tween, 'tween_all_completed')

    emit_signal('fade_from_black_finished')

func _fade(old: float, new: float, duration: float, delay: float, fade_music: bool) -> void:
    _set_fade_music(fade_music)

    _fade_tween.remove_all()
    _fade_tween.interpolate_property(
        _black_overlay, 'modulate:a', old, new, duration, Tween.TRANS_LINEAR,
        Tween.EASE_IN, delay)
    _fade_tween.start()

func _set_fade_music(fade_music: bool) -> void:
    if fade_music:
        _fade_tween.connect('tween_step', self, '_on_tween_step')
    else:
        _fade_tween.disconnect('tween_step', self, '_on_tween_step')

func _on_tween_step(obj, key, elapsed, val: float) -> void:
    # Fade music/effects at the same rate as the screen. Take advantage of the
    # fact that the value here (i.e. the black overlay alpha) is already in
    # [0, 1].
    Audio.set_bus_volume_linear('Music', 1.0 - val)
    Audio.set_bus_volume_linear('Effects', 1.0 - val)
