extends Node
class_name UiSoundPlayer

onready var _ui_navigation_sound: AudioStreamPlayer = $Navigation

func play_ui_navigation_sound() -> void:
    _ui_navigation_sound.play()
