extends "res://game/game_interface.gd"

func _ready() -> void:
    MusicPlayer.stop_all()

    _player.change_state({'new_state': Player.State.SUSPENDED})

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        set_process_unhandled_input(false)
        _proceed()

func _proceed() -> void:
    _player.change_state({'new_state': Player.State.FALL})

    MusicPlayer.play(MusicPlayer.Music.ARENA_START)
    yield(MusicPlayer.get_player(MusicPlayer.Music.ARENA_START), 'finished')

    get_tree().quit()
