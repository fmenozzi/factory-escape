extends Room

onready var _fragile_platform: FragilePlatform = $FragilePlatform

var _is_broken := false

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _is_broken:
            _fragile_platform.reset()
        else:
            _fragile_platform.break()
        _is_broken = not _is_broken
