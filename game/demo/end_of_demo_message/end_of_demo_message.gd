extends Control

func _ready() -> void:
    MusicPlayer.stop_all()
    var factory_background: AudioStreamPlayerMusic = MusicPlayer.get_player(
        MusicPlayer.Music.FACTORY_BACKGROUND)
    factory_background.set_max_volume_db(0.0)
    factory_background.play()

    set_process_unhandled_input(false)
    yield(SceneChanger, 'scene_changed')
    set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
    # Once the scene trasition completes, any key/button press advances back to
    # the main menu.
    if event is InputEventKey or event is InputEventJoypadButton:
        set_process_unhandled_input(false)

        var fade_in_delay := 2.0
        SceneChanger.change_scene_to(Preloads.TitleScreen, fade_in_delay)
