extends 'res://actors/shared/states/state.gd'

const PAUSE_DURATION := 1.0

onready var _pause_duration_timer: Timer = $PauseDuration

func _ready() -> void:
    _pause_duration_timer.one_shot = true
    _pause_duration_timer.wait_time = PAUSE_DURATION

func enter(platform: SinkingPlatform, previous_state_dict: Dictionary) -> void:
    platform.get_animation_player().stop()

    _pause_duration_timer.start()

func exit(platform: SinkingPlatform) -> void:
    pass

func update(platform: SinkingPlatform, delta: float) -> Dictionary:
    if _pause_duration_timer.is_stopped():
        if platform.player_on_platform():
            return {'new_state': SinkingPlatform.State.SHAKE}
        else:
            return {'new_state': SinkingPlatform.State.GOING_UP}

    return {'new_state': SinkingPlatform.State.NO_CHANGE}
