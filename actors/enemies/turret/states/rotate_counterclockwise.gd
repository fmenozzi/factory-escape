extends 'res://actors/enemies/enemy_state.gd'

const ROTATION_DURATION: float = 3.0

var _rotation_speed := 0.0

onready var _rotation_duration_timer: Timer = $RotationDurationTimer

func _ready() -> void:
    _rotation_duration_timer.one_shot = true
    _rotation_duration_timer.wait_time = ROTATION_DURATION

    _rotation_speed = PI / ROTATION_DURATION

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    _rotation_duration_timer.start()

func exit(turret: Turret) -> void:
    _rotation_duration_timer.stop()

func update(turret: Turret, delta: float) -> Dictionary:
    turret.rotate_head(-1 * _rotation_speed * delta)

    if _rotation_duration_timer.is_stopped():
        return {'new_state': Turret.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Turret.State.NO_CHANGE}
