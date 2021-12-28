extends Particles2D

func start_and_queue_free() -> void:
    emitting = true
    yield(get_tree().create_timer(lifetime * 2), 'timeout')
    queue_free()
