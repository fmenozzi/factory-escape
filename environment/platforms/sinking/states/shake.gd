extends 'res://actors/shared/states/state.gd'

const SHAKE_DURATION := 0.25

onready var _shake_duration_timer: Timer = $ShakeDuration

func _ready() -> void:
    _shake_duration_timer.one_shot = true
    _shake_duration_timer.wait_time = SHAKE_DURATION

func enter(platform: SinkingPlatform, previous_state_dict: Dictionary) -> void:
    platform.get_animation_player().stop()

    _shake_duration_timer.start()

func exit(platform: SinkingPlatform) -> void:
    pass

func update(platform: SinkingPlatform, delta: float) -> Dictionary:
    var damping := ease(_shake_duration_timer.time_left / SHAKE_DURATION, 1.0)
    platform.shake_once(damping)

    if _shake_duration_timer.is_stopped():
        platform.reset_sprite_position()
        if platform.player_on_platform():
            return {'new_state': SinkingPlatform.State.GOING_DOWN}
        else:
            return {'new_state': SinkingPlatform.State.GOING_UP}

    return {'new_state': SinkingPlatform.State.NO_CHANGE}
