extends Room

const SAVE_KEY := 'abilities_lamp'

onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _door_trigger: Area2D = $ClosingDoorTrigger

var _player_entered_room := false

func _ready() -> void:
    _door_trigger.connect('body_entered', self, '_on_player_entered_room')

func _on_player_entered_room(player: Player) -> void:
    if not player:
        return

    _player_entered_room = true

    _closing_door.close()

    # As of 3.2 we need to use call_deferred here.
    _door_trigger.call_deferred(
        'disconnect', 'body_entered', self, '_on_player_entered_room')

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'player_entered_room': _player_entered_room,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var abilities_lamp_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('player_entered_room' in abilities_lamp_save_data)

    _player_entered_room = abilities_lamp_save_data['player_entered_room']

    # If we've already entered the room, disconnect the door trigger signal and
    # close the door.
    if _player_entered_room:
        _door_trigger.disconnect('body_entered', self, '_on_player_entered_room')
        _closing_door.close()
