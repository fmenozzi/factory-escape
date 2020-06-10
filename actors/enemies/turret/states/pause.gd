extends 'res://actors/enemies/enemy_state.gd'

const PAUSE_DURATION: float = 1.0

onready var _pause_duration_timer: Timer = $PauseDurationTimer

func _ready() -> void:
    _pause_duration_timer.one_shot = true
    _pause_duration_timer.wait_time = PAUSE_DURATION

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    turret.change_rotation_direction()

    _pause_duration_timer.start()

func exit(turret: Turret) -> void:
    _pause_duration_timer.stop()

func update(turret: Turret, delta: float) -> Dictionary:
    if _pause_duration_timer.is_stopped():
        return {
            'new_state': Turret.State.ROTATE,
            'rotation_direction': turret.get_rotation_direction(),
        }

    return {'new_state': Turret.State.NO_CHANGE}
