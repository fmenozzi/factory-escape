extends Node2D
class_name Switch

signal state_changed(new_state)

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _label_area: Area2D = $LabelArea

enum State {
    PRESSED,
    UNPRESSED,
}

func _ready() -> void:
    _label_area.connect('body_entered', self, '_on_player_entered')
    _label_area.connect('body_exited', self, '_on_player_exited')

func change_state(new_state: int) -> void:
    assert(new_state in [State.PRESSED, State.UNPRESSED])

    match new_state:
        State.PRESSED:
            _animation_player.play('pressed')

        State.UNPRESSED:
            _animation_player.play('unpressed')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_switch(self)

    _fade_in_out_label.fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_switch(null)

    _fade_in_out_label.fade_out()
