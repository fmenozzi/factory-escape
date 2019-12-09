extends Node2D

onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _closing_door_trigger: Area2D = $ClosingDoorTrigger

func _ready() -> void:
    _closing_door_trigger.connect('body_entered', self, '_on_player_entered')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    if not _closing_door.is_closed():
        _closing_door.close()