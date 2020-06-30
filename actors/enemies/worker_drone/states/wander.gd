extends 'res://actors/enemies/enemy_state.gd'

const ANGLE_MEAN := 0.0
const ANGLE_STD := deg2rad(3)

var _rng := RandomNumberGenerator.new()
var _velocity := Vector2.ZERO

func _ready() -> void:
    _rng.randomize()

func enter(worker_drone: WorkerDrone, previous_state_dict: Dictionary) -> void:
    # Initial direction is random.
    var speed = worker_drone.get_physics_manager().get_movement_speed()
    var direction = Vector2(_rng.randf(), _rng.randf()).normalized()
    _velocity = speed * direction

func exit(worker_drone: WorkerDrone) -> void:
    pass

func update(worker_drone: WorkerDrone, delta: float) -> Dictionary:
    # Deviate from the previous direction by randomly rotating the velocity
    # vector. Sample from a normal distribution instead of a uniform one to
    # produce less chaotic motion.
    _velocity = _velocity.rotated(_rng.randfn(ANGLE_MEAN, ANGLE_STD))
    worker_drone.move(_velocity)

    # If we hit an obstacle, start moving in the opposite direction.
    if worker_drone.is_hitting_obstacle():
        _velocity = _velocity.rotated(PI)
        worker_drone.move(_velocity)

    return {'new_state': WorkerDrone.State.NO_CHANGE}
