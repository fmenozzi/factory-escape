extends Node2D

func _ready() -> void:
    $ClosingDoorTrigger.connect('body_entered', self, '_on_player_entered')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    $ClosingDoor.close()