extends 'res://actors/enemies/enemy_state.gd'

onready var _timer: Timer = $ActivateDuration

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = 1.0

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    warden.emit_signal('lightning_floor_activated')

    _timer.start()

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if _timer.is_stopped():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
