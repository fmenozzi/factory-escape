extends Area2D

signal end_of_demo_reached

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    emit_signal('end_of_demo_reached')
