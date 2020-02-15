extends Node
class_name ElapsedTimer

enum Process {
    IDLE,
    PHYSICS,
}

var _elapsed_time: float = 0.0

func _process(delta: float) -> void:
    _update(delta)

func _physics_process(delta: float) -> void:
    _update(delta)

func start(process: int) -> void:
    assert(process in [Process.IDLE, Process.PHYSICS])

    stop()

    match process:
        Process.IDLE:
            set_process(true)

        Process.PHYSICS:
            set_physics_process(true)

func stop() -> void:
    _elapsed_time = 0.0

    set_process(false)
    set_physics_process(false)

func get_elapsed_time() -> float:
    return _elapsed_time

func _update(delta: float) -> void:
    _elapsed_time += delta
