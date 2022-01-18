extends Particles2D

onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = 2 * lifetime
    _timer.connect('timeout', self, 'queue_free')

func start_and_queue_free() -> void:
    emitting = true
    _timer.start()
