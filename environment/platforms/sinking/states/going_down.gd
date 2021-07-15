extends 'res://actors/shared/states/state.gd'

const SPEED := 2.0 * Util.TILE_SIZE

func enter(platform: SinkingPlatform, previous_state_dict: Dictionary) -> void:
    platform.get_animation_player().play('move')

func exit(platform: SinkingPlatform) -> void:
    pass

func update(platform: SinkingPlatform, delta: float) -> Dictionary:
    var platform_body := platform.get_platform()
    platform_body.position.y += SPEED * delta

    if platform_body.position.y >= platform.get_destination().position.y:
        platform_body.position.y = platform.get_destination().position.y
        return {'new_state': SinkingPlatform.State.IDLE_BOTTOM}

    if not platform.player_on_platform():
        return {'new_state': SinkingPlatform.State.PAUSE_BEFORE_GOING_UP}

    return {'new_state': SinkingPlatform.State.NO_CHANGE}
