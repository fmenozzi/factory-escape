extends Node2D

signal health_pack_taken(health_pack)

onready var _pickup_area: Area2D = $PickupArea
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel

var _player: Player
var _taken := false

func _ready() -> void:
    _pickup_area.connect('body_entered', self, '_on_player_entered')
    _pickup_area.connect('body_exited', self, '_on_player_exited')

    _animation_player.play('spawn')

    set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent):
    if event.is_action_pressed('player_interact'):
        if _player.current_state() in [Player.State.IDLE, Player.State.WALK]:
            if not _taken:
                _taken = true
                _animation_player.play('taken')
                _fade_in_out_label.fade_out()
                set_process_unhandled_input(false)
                emit_signal('health_pack_taken', self)

func reset() -> void:
    _animation_player.play('spawn')
    _taken = false

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    if _taken:
        return

    _player = player
    _fade_in_out_label.fade_in()

    set_process_unhandled_input(true)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    if _taken:
        return

    _player = null
    _fade_in_out_label.fade_out()

    set_process_unhandled_input(false)
