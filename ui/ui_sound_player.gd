extends Node
class_name UiSoundPlayer

onready var _ui_navigation_sound: AudioStreamPlayer = $Navigation
onready var _ui_menu_changed_sound: AudioStreamPlayer = $MenuChanged
onready var _ui_start_game_sound: AudioStreamPlayer = $StartGame

func play_ui_navigation_sound() -> void:
    _ui_navigation_sound.play()

func play_menu_changed_sound() -> void:
    _ui_menu_changed_sound.play()

func play_start_game_sound() -> void:
    _ui_start_game_sound.play()
