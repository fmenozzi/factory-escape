extends Room

const SAVE_KEY := 'abilities_lamp'

onready var _lamp: Area2D = $Lamp
onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _door_trigger: Area2D = $ClosingDoorTrigger

var _rested_at_lamp := false

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
    _rested_at_lamp = true

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'rested_at_lamp': _rested_at_lamp,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var abilities_lamp_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('rested_at_lamp' in abilities_lamp_save_data)

    _rested_at_lamp = abilities_lamp_save_data['rested_at_lamp']

    # If we've already rested at the lamp, disconnect the lamp rested and door
    # triggered signals and close the door.
    if _rested_at_lamp:
        _lamp.disconnect('rested_at_lamp', self, '_on_rested_at_lamp')
        _door_trigger.disconnect('body_entered', self, '_on_player_entered_room')
        _closing_door.close()
