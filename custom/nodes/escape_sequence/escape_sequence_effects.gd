extends CanvasLayer

onready var _shake_timer: Timer = $ShakeTimer

func _ready() -> void:
    _shake_timer.one_shot = false
    _shake_timer.connect('timeout', self, '_on_shake_timeout')

func start() -> void:
    _shake_timer.start(0.1)

func stop() -> void:
    _shake_timer.stop()

func lamp_reset() -> void:
    stop()

func _on_shake_timeout() -> void:
    Screenshake.start(
        Screenshake.Duration.MEDIUM, Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.5, Rumble.Priority.HIGH)

    _shake_timer.start(rand_range(1.0, 7.0))
