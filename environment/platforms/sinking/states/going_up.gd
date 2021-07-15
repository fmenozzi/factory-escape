extends 'res://actors/shared/states/state.gd'

const SPEED := 3.0 * Util.TILE_SIZE

var _started_with_player_on_platform := false

func enter(platform: SinkingPlatform, previous_state_dict: Dictionary) -> void:
    platform.get_animation_player().play('move')

    _started_with_player_on_platform = platform.player_on_platform()

func exit(platform: SinkingPlatform) -> void:
    pass

func update(platform: SinkingPlatform, delta: float) -> Dictionary:
    var platform_body := platform.get_platform()
    platform_body.position.y -= SPEED * delta

    if platform_body.position.y <= 0:
        platform_body.position.y = 0
        return {'new_state': SinkingPlatform.State.IDLE_TOP}

    if _started_with_player_on_platform and not platform.player_on_platform():
        return {'new_state': SinkingPlatform.State.SHAKE}

    if not _started_with_player_on_platform and platform.player_on_platform():
        return {'new_state': SinkingPlatform.State.GOING_DOWN}

    return {'new_state': SinkingPlatform.State.NO_CHANGE}
