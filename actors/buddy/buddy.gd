extends KinematicBody2D
class_name Buddy

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _dialog_area: Area2D = $DialogArea
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _dialog_walk_to_points: Node2D = $WalkToPoints

func _ready() -> void:
    _animation_player.play('idle')

    _dialog_area.connect('body_entered', self, '_on_player_entered')
    _dialog_area.connect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _fade_in_out_label.fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    _fade_in_out_label.fade_out()
