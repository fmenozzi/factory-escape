extends Node2D
class_name Switch

signal state_changed(new_state)

onready var _animation_player: AnimationPlayer = $AnimationPlayer

enum State {
    PRESSED,
    UNPRESSED,
}

func change_state(new_state: int) -> void:
    assert(new_state in [State.PRESSED, State.UNPRESSED])

    match new_state:
        State.PRESSED:
            _animation_player.play('pressed')

        State.UNPRESSED:
            _animation_player.play('unpressed')
