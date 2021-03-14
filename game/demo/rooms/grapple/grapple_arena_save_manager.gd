extends Node
class_name GrappleArenaSaveManager

const SAVE_KEY := 'grapple_arena'

onready var _arena: Room = get_parent()
onready var current_room_state: int = _arena.RoomState.PRE_FIGHT

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'current_room_state': current_room_state,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var arena_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('current_room_state' in arena_save_data)

    # If we haven't already completed the arena, make sure room state gets set
    # to PRE_FIGHT (i.e. in case the player quits out during one of the waves).
    current_room_state = arena_save_data['current_room_state']
    if current_room_state != _arena.RoomState.POST_FIGHT:
        current_room_state = _arena.RoomState.PRE_FIGHT

    # If we've already completed the arena, disconnect the door trigger signal.
    if current_room_state == _arena.RoomState.POST_FIGHT:
        _arena._door_trigger.disconnect('body_entered', _arena, '_start_arena')
