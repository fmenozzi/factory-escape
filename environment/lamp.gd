extends Area2D

signal rested_at_lamp(lamp)

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _player: Player = Util.get_player()

func _ready() -> void:
    _animation_player.play('lamp')

    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        if _player.current_state() == Player.State.REST:
            _player.change_state({'new_state': Player.State.IDLE})
            return

        if _player.get_nearby_lamp() == self:
            emit_signal('rested_at_lamp', self)

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_lamp(self)

    fade_in_label()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_lamp(null)

    fade_out_label()

func fade_in_label() -> void:
    _fade_in_out_label.fade_in()

func fade_out_label() -> void:
    _fade_in_out_label.fade_out()