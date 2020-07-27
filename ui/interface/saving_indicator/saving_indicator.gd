extends Control

signal spinning_started
signal spinning_finished

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.one_shot = true
    _timer.connect('timeout', self, '_on_timeout')

    stop_spinning()

func start_spinning_for(duration: float) -> void:
    _animation_player.play('spin')

    if duration > 0.0:
        _timer.wait_time = duration
        _timer.start()

    self.visible = true

    emit_signal('spinning_started')

func stop_spinning() -> void:
    _animation_player.stop(true)

    _timer.stop()

    self.visible = false

    emit_signal('spinning_finished')

func is_spinning() -> bool:
    return _animation_player.is_playing()

func _on_timeout() -> void:
    stop_spinning()
