extends Node

signal scene_changed

onready var _screen_fadeout: Control = $ScreenFadeout

var _is_changing_scene := false

func change_scene_to(scene: PackedScene, fade_duration: float) -> void:
    if _is_changing_scene:
        return

    _is_changing_scene = true

    _screen_fadeout.fade_to_black(fade_duration)
    yield(_screen_fadeout, 'fade_to_black_finished')

    var status := get_tree().change_scene_to(scene)
    assert(status == OK)

    # If we're going from the pause menu back to the title screen, unpause the
    # tree.
    if get_tree().paused:
        get_tree().paused = false

    _screen_fadeout.fade_from_black(fade_duration)
    yield(_screen_fadeout, 'fade_from_black_finished')

    _is_changing_scene = false

    emit_signal('scene_changed')

func is_changing_scene() -> bool:
    return _is_changing_scene
