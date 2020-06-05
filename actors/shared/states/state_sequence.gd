extends 'res://actors/shared/states/state.gd'

signal sequence_finished

var _active_state: Node = null
var _initial_metadata: Dictionary = {}

func _get_configuration_warning() -> String:
    if get_child_count() == 0:
        return 'State sequence must have children state nodes!'
    return ''

func _ready() -> void:
    assert(get_child_count() > 0)

func enter(actor, previous_state_dict: Dictionary) -> void:
    _initial_metadata = previous_state_dict.duplicate(true)
    _initial_metadata.erase('previous_state')

    # Start with the first child state node and proceed sequentially.
    _active_state = get_child(0)
    _active_state.enter(actor, previous_state_dict)

func exit(actor) -> void:
    pass

func update(actor, delta: float) -> Dictionary:
    var new_state_dict: Dictionary = _active_state.update(actor, delta)
    if new_state_dict['new_state'] != actor.State.NO_CHANGE:
        _active_state.exit(actor)

        _merge_initial_metadata(new_state_dict)

        var new_state_index := _active_state.get_index() + 1
        if new_state_index >= get_child_count():
            # Once we finish with the last state in the sequence, transition to
            # that state's next state.
            emit_signal('sequence_finished')
            return new_state_dict

        # Before passing along the new_state_dict to the new state (since we
        # want any additional metadata keys passed too), rename the 'new_state'
        # key to 'previous_state'. It's important that we do this AFTER
        # potentially returning the new state dict back to the state sequence,
        # since we need the new_state key for that.
        new_state_dict['previous_state'] = new_state_dict['new_state']
        new_state_dict.erase('new_state')

        _active_state = get_child(new_state_index)
        _active_state.enter(actor, new_state_dict)

    return {'new_state': actor.State.NO_CHANGE}

func _merge_initial_metadata(existing_metadata: Dictionary) -> void:
    for key in _initial_metadata:
        existing_metadata[key] = _initial_metadata[key]
