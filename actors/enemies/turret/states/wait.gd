extends 'res://actors/enemies/enemy_state.gd'

const WAIT_DURATION: float = 1.0

onready var _wait_duration_timer: Timer = $WaitDurationTimer

func _ready() -> void:
    _wait_duration_timer.one_shot = true
    _wait_duration_timer.wait_time = WAIT_DURATION

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    turret.change_rotation_direction()

    _wait_duration_timer.start()

    # Show scan line.
    turret.get_scanner().visible = true

func exit(turret: Turret) -> void:
    _wait_duration_timer.stop()

func update(turret: Turret, delta: float) -> Dictionary:
    var scanner := turret.get_scanner()
    var aggro_manager := turret.get_aggro_manager()

    if scanner.is_colliding_with_player():
        return {
            'new_state': Turret.State.ALERTED,
            'already_aggroed': false
        }

    if _wait_duration_timer.is_stopped():
        return {
            'new_state': Turret.State.ROTATE,
            'rotation_direction': turret.get_rotation_direction(),
        }

    return {'new_state': Turret.State.NO_CHANGE}
