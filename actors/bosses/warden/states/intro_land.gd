extends 'res://actors/enemies/enemy_state.gd'

const LAND_DURATION := 2.0

onready var _timer: Timer = $LandDuration

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = LAND_DURATION

func enter(warden: Warden, previous_state_dict: Dictionary) -> void:
    Screenshake.start(
        Screenshake.Duration.LONG, Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 1.0, Rumble.Priority.HIGH)

    _timer.start()

func exit(warden: Warden) -> void:
    pass

func update(warden: Warden, delta: float) -> Dictionary:
    if _timer.is_stopped():
        return {'new_state': Warden.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': Warden.State.NO_CHANGE}
