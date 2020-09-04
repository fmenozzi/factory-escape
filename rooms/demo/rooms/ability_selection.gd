extends Room

onready var _closing_door_left: StaticBody2D = $ClosingDoorLeft
onready var _closing_door_right: StaticBody2D = $ClosingDoorRight
onready var _door_trigger: Area2D = $ClosingDoorTrigger

func _ready() -> void:
    _door_trigger.connect('body_entered', self, '_on_player_entered_room')

func _on_player_entered_room(player: Player) -> void:
    if not player:
        return

    _closing_door_left.close()
    _closing_door_right.close()

    # As of 3.2 we need to use call_deferred here.
    _door_trigger.call_deferred(
        'disconnect', 'body_entered', self, '_on_player_entered_room')

func _on_ability_chosen(chosen_ability: int) -> void:
    # Only open the door on the right.
    _closing_door_right.open()
