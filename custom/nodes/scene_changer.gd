extends Node

signal scene_changed

onready var _screen_fadeout: Control = $ScreenFadeout

func change_scene_to(scene: PackedScene, fade_duration: float) -> void:
    _screen_fadeout.fade_to_black(fade_duration)
    yield(_screen_fadeout, 'fade_to_black_finished')

    assert(get_tree().change_scene_to(scene) == OK)

    _screen_fadeout.fade_from_black(fade_duration)
    yield(_screen_fadeout, 'fade_from_black_finished')

    emit_signal('scene_changed')
