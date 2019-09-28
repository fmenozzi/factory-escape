extends Node

signal flashing_ended

onready var _timer: Timer = $Timer
onready var _tween: Tween = $SpriteFlashTween

const INVINCIBILITY_DURATION: float = 2.0

func setup(sprite: Sprite) -> void:
    # Setup invincibility timer.
    _timer.one_shot = true
    _timer.wait_time = INVINCIBILITY_DURATION
    _timer.connect('timeout', self, '_on_flashing_timeout')

    # Setup invincibility tween (for flashing player sprite while invincible).
    var prop := 'modulate'
    var duration := 0.075
    var old := Color(1, 1, 1, 1)
    var new := Color(10, 10, 10, 1)
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN
    var delay := duration
    _tween.interpolate_property(sprite, prop, old, new, duration, trans, easing)
    _tween.interpolate_property(
        sprite, prop, new, old, duration, trans, easing, delay)

func start_flashing() -> void:
    _timer.start()
    _tween.resume_all()

func stop_flashing() -> void:
    _tween.reset_all()
    _tween.stop_all()

func pause_timer() -> void:
    _timer.paused = true
func resume_timer() -> void:
    _timer.paused = false

func _on_flashing_timeout() -> void:
    stop_flashing()
    emit_signal('flashing_ended')
