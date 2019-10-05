extends Control

signal fade_out_completed
signal fade_in_completed

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func fade_out(delay: float = 0.0) -> void:
    yield(get_tree().create_timer(delay), 'timeout')

    _animation_player.play('fade_out')
    yield(_animation_player, 'animation_finished')

    emit_signal('fade_out_completed')

func fade_in(delay: float = 0.0) -> void:
    yield(get_tree().create_timer(delay), 'timeout')

    _animation_player.play_backwards('fade_out')
    yield(_animation_player, 'animation_finished')

    emit_signal('fade_in_completed')