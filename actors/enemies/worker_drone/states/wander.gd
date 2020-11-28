extends 'res://actors/enemies/enemy_state.gd'

var _rng := RandomNumberGenerator.new()
var _velocity := Vector2.ZERO

func _ready() -> void:
    _rng.randomize()

    # Initial direction is random.
    _velocity = Vector2.RIGHT.rotated(_rng.randf())

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    var speed := worker_drone.get_physics_manager().get_movement_speed()
    _velocity = speed * _velocity.normalized()

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    # Continue moving in a straight line until we hit an obstacle, at which
    # point we bounce away from it.
    worker_drone.move(_velocity)
    if worker_drone.is_hitting_obstacle():
        _velocity = _velocity.bounce(worker_drone.get_slide_collision(0).normal)

    return {'new_state': WorkerDrone.State.NO_CHANGE}
