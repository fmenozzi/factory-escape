extends Node

signal rumble_started
signal rumble_stopped

enum Type {
    WEAK,
    STRONG,
}

enum Priority {
    LOW,
    HIGH,
}
var _priority: int = Priority.LOW

var _is_rumbling := false
var _strength_multiplier := 1.0

onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.connect('timeout', self, '_on_rumble_timeout')

func start(type: int, duration: float, priority: int = Priority.LOW) -> void:
    assert(type in [Type.WEAK, Type.STRONG])

    if priority < _priority:
        return

    _priority = priority

    match type:
        Type.WEAK:
            Input.start_joy_vibration(0, 0.25 * _strength_multiplier, 0, duration)

        Type.STRONG:
            Input.start_joy_vibration(0, 0.50 * _strength_multiplier, 0, duration)

    _timer.wait_time = duration
    _timer.start()

    _is_rumbling = true

    emit_signal('rumble_started')

func stop() -> void:
    if not _is_rumbling:
        return

    Input.stop_joy_vibration(0)

    _is_rumbling = false
    _priority = Priority.LOW

    emit_signal('rumble_stopped')

func set_strength_multiplier(strength_multiplier: float) -> void:
    assert(strength_multiplier >= 0)

    _strength_multiplier = strength_multiplier

func _on_rumble_timeout() -> void:
    stop()
