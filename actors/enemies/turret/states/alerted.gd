extends 'res://actors/enemies/enemy_state.gd'

const ALERTED_DURATION: float = 1.0

onready var _alerted_duration_timer: Timer = $AlertedDurationTimer

func _ready() -> void:
    _alerted_duration_timer.one_shot = true
    _alerted_duration_timer.wait_time = ALERTED_DURATION

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    # Display alerted reaction.
    turret.get_react_sprite().change_state(ReactSprite.State.ALERTED)

    _alerted_duration_timer.start()

func exit(turret: Turret) -> void:
    # Hide reaction sprite.
    turret.get_react_sprite().change_state(ReactSprite.State.NONE)

    _alerted_duration_timer.stop()

func update(turret: Turret, delta: float) -> Dictionary:
    if _alerted_duration_timer.is_stopped():
        return {
            'new_state': Turret.State.ROTATE,
            'rotation_direction': turret.get_rotation_direction(),
        }

    return {'new_state': Turret.State.NO_CHANGE}
