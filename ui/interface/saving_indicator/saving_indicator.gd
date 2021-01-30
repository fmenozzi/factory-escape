extends Control

signal spinning_started
signal spinning_finished

const TRANSPARENT := 0.0
const OPAQUE := 1.0

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _sprites: Node2D = $Sprites
onready var _tween: Tween = $Sprites/VisibilityTween
onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.one_shot = true
    _timer.connect('timeout', self, '_on_timeout')

    _sprites.modulate.a = 0.0

func start_spinning_for(duration: float) -> void:
    _animation_player.play('spin')

    if duration > 0.0:
        _timer.wait_time = duration
        _timer.start()

    _fade_spinner(TRANSPARENT, OPAQUE)

    emit_signal('spinning_started')

func stop_spinning() -> void:
    _timer.stop()

    _fade_spinner(OPAQUE, TRANSPARENT)

    yield(_tween, 'tween_all_completed')
    _animation_player.stop(true)

    emit_signal('spinning_finished')

func is_spinning() -> bool:
    return _animation_player.is_playing()

func _fade_spinner(old: float, new: float) -> void:
    var duration := 0.25

    _tween.remove_all()
    _tween.interpolate_property(
        _sprites, 'modulate:a', old, new, duration, Tween.TRANS_QUAD,
        Tween.EASE_IN)
    _tween.start()

func _on_timeout() -> void:
    stop_spinning()
