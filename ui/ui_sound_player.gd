extends Node
class_name UiSoundPlayer

onready var _ui_navigation_sound: AudioStreamPlayer = $Navigation
onready var _ui_menu_changed_sound: AudioStreamPlayer = $MenuChanged

func play_ui_navigation_sound() -> void:
    _ui_navigation_sound.play()

func play_menu_changed_sound() -> void:
    _ui_menu_changed_sound.play()
