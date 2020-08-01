extends Node2D

signal health_pack_taken(health_pack)

onready var _pickup_area: Area2D = $PickupArea
onready var _fade_in_out_label: Label = $FadeInOutLabel

var _player: Player
var _taken := false

func _ready() -> void:
    _pickup_area.connect('body_entered', self, '_on_player_entered')
    _pickup_area.connect('body_exited', self, '_on_player_exited')

    set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent):
    if event.is_action_pressed('player_interact'):
        if _player.current_state() == Player.State.IDLE:
            if not _taken:
                _taken = true
                self.visible = false
                set_process_unhandled_input(false)
                emit_signal('health_pack_taken', self)

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
