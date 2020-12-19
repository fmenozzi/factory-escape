extends Room

onready var _lamp: Area2D = $Lamp
onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _door_trigger: Area2D = $ClosingDoorTrigger
onready var _save_manager: AbilitiesLampSaveManager = $SaveManager

func _ready() -> void:
    _lamp.connect('rested_at_lamp', self, '_on_rested_at_lamp')

    _door_trigger.connect('body_entered', self, '_on_player_entered_room')

func _on_player_entered_room(player: Player) -> void:
    if not player:
        return

    _closing_door.close()

    # As of 3.2 we need to use call_deferred here.
    _door_trigger.call_deferred(
        'disconnect', 'body_entered', self, '_on_player_entered_room')

func _on_rested_at_lamp(lamp: Area2D) -> void:
    _save_manager.rested_at_lamp = true

func lamp_reset() -> void:
    if not _save_manager.rested_at_lamp:
        _closing_door.open()
        _door_trigger.connect('body_entered', self, '_on_player_entered_room')
