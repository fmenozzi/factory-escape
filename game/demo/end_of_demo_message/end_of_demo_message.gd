extends Control

func _ready() -> void:
    set_process_unhandled_input(false)

    SceneChanger.connect('scene_changed', self, '_on_scene_changed')

func _unhandled_input(event: InputEvent) -> void:
    # Once the scene trasition completes, any key/button press advances back to
    # the main menu.
    if event is InputEventKey or event is InputEventJoypadButton:
        set_process_unhandled_input(false)

        var fade_in_delay := 2.0
        SceneChanger.change_scene_to(Preloads.TitleScreen, fade_in_delay)

func _on_scene_changed() -> void:
    set_process_unhandled_input(true)
