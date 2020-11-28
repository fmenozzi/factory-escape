extends Sprite
class_name ReactSprite

enum State {
    NONE,
    ALERTED,
    UNALERTED,
}

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func change_state(state: int) -> void:
    assert(state in [State.NONE, State.ALERTED, State.UNALERTED])

    match state:
        State.NONE:
            self.visible = false

        State.ALERTED:
            _animation_player.play('alerted')
            self.visible = true

        State.UNALERTED:
            _animation_player.play('unalerted')
            self.visible = true
