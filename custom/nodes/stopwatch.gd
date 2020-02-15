extends Node
class_name Stopwatch

signal stopwatch_started
signal stopwatch_stopped

enum Process {
    IDLE,
    PHYSICS,
}
export(Process) var process_mode := Process.PHYSICS

var _elapsed_time: float = 0.0

func _process(delta: float) -> void:
    _update(delta)

func _physics_process(delta: float) -> void:
    _update(delta)

func start() -> void:
    _reset()

    match process_mode:
        Process.IDLE:
            set_process(true)

        Process.PHYSICS:
            set_physics_process(true)

    emit_signal('stopwatch_started')

func stop() -> float:
    var elapsed_time := _elapsed_time

    _reset()

    emit_signal('stopwatch_stopped')

    return elapsed_time

func get_elapsed_time() -> float:
    return _elapsed_time

func _update(delta: float) -> void:
    _elapsed_time += delta

func _reset() -> void:
    _elapsed_time = 0.0

    set_process(false)
    set_physics_process(false)
