extends Control

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        set_process_unhandled_input(false)
        _proceed()

func _proceed() -> void:
    $AnimationPlayer.play('fade_in')
    yield($AnimationPlayer, 'animation_finished')
    get_tree().quit()
