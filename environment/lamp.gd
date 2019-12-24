extends Area2D

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _fade_in_out_label: Label = $FadeInOutLabel

func _ready() -> void:
    _animation_player.play('lamp')

    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _fade_in_out_label.fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    _fade_in_out_label.fade_out()