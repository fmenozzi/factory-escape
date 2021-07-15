extends 'res://actors/shared/states/state.gd'

func enter(platform: SinkingPlatform, previous_state_dict: Dictionary) -> void:
    platform.get_animation_player().stop()

func exit(platform: SinkingPlatform) -> void:
    pass

func update(platform: SinkingPlatform, delta: float) -> Dictionary:
    if platform.player_on_platform():
        return {'new_state': SinkingPlatform.State.SHAKE}

    return {'new_state': SinkingPlatform.State.NO_CHANGE}
