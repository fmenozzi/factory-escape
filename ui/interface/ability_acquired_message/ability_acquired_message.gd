extends Control

signal message_shown

onready var _label: Label = $CenterContainer/Label
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func show_message(message: String) -> void:
    _label.text = message

    _animation_player.play('show_message')
    yield(_animation_player, 'animation_finished')

    emit_signal('message_shown')
