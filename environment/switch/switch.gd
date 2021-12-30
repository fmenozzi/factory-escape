extends Node2D
class_name Switch

signal switch_press_started(switch, resume_player_processing_after_pressed)
signal switch_press_finished

export(bool) var resume_player_processing_after_pressed := true

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _label_area: Area2D = $LabelArea
onready var _walk_to_points: Node2D = $WalkToPoints
onready var _player: Player = Util.get_player()

enum State {
    PRESSED,
    UNPRESSED,
}

var _state: int = State.UNPRESSED

func _ready() -> void:
    _label_area.connect('body_entered', self, '_on_player_entered')
    _label_area.connect('body_exited', self, '_on_player_exited')

    reset_state_to(State.UNPRESSED)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _player.get_nearby_switch() != self:
            return

        # Only allow interacting with switches while idle or walking near them.
        if not _player.current_state() in [Player.State.IDLE, Player.State.WALK]:
            return

        # Player can only directly interact with UNPRESSED switches (though
        # these can be reset externally).
        if _state == State.PRESSED:
            return

        emit_signal('switch_press_started', self, resume_player_processing_after_pressed)

func reset_state_to(new_state: int) -> void:
    assert(new_state in [State.PRESSED, State.UNPRESSED])

    if _state == new_state:
        return

    var player_near_switch: bool = (Util.get_player().get_nearby_switch() == self)

    match new_state:
        State.PRESSED:
            _animation_player.play('pressed')

            if player_near_switch:
                _fade_in_out_label.fade_out()

        State.UNPRESSED:
            _animation_player.play('unpressed')

            if player_near_switch:
                _fade_in_out_label.fade_in()

    _state = new_state

func get_closest_walk_to_point() -> Position2D:
    return _walk_to_points.get_closest_point()

func fade_out_label() -> void:
    _fade_in_out_label.fade_out()

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_switch(self)

    if _state == State.UNPRESSED:
        _fade_in_out_label.fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_switch(null)

    if _state == State.UNPRESSED:
        _fade_in_out_label.fade_out()
