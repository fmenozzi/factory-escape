extends Node2D
class_name Switch

signal state_changed(switch, new_state)
signal switch_pressed

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

    change_state(State.UNPRESSED)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _player.get_nearby_switch() != self:
            return

        # Only allow interacting with switches while idle or walking near them.
        if not _player.current_state() in [Player.State.IDLE, Player.State.WALK]:
            return

        if _state == State.UNPRESSED:
            change_state(State.PRESSED)

func change_state(new_state: int) -> void:
    assert(new_state in [State.PRESSED, State.UNPRESSED])

    match new_state:
        State.PRESSED:
            # Once pressed, switches remain pressed (unless reset externally).
            _label_area.disconnect('body_entered', self, '_on_player_entered')
            _label_area.disconnect('body_exited', self, '_on_player_exited')

        State.UNPRESSED:
            _animation_player.play('unpressed')

    _state = new_state

    emit_signal('state_changed', self, new_state)

func get_closest_walk_to_point() -> Position2D:
    return _walk_to_points.get_closest_point()

func fade_out_label() -> void:
    _fade_in_out_label.fade_out()

func set_sprite_to_pressed() -> void:
    _animation_player.play('pressed')

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
