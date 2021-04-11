extends Node

onready var _arena: Arena = get_parent()
onready var _save_key: String = get_parent().get_path()

var current_phase_index := -1

func get_save_data() -> Array:
    return [_save_key, {
        'current_phase_index': current_phase_index,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var arena_save_data: Dictionary = all_save_data[_save_key]
    assert('current_phase_index' in arena_save_data)

    # If we haven't already completed the arena, make sure the current phase
    # index state gets set to -1 (i.e. in case the player quits out during one
    # of the phases).
    current_phase_index = arena_save_data['current_phase_index']
    if current_phase_index < _arena._num_phases:
        current_phase_index = -1

    # If we've already completed the arena, disconnect the door trigger signal.
    if current_phase_index >= _arena._num_phases:
        _arena._trigger.disconnect('body_entered', _arena, '_start_arena')
