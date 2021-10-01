extends Node2D
class_name LightningFloor

enum State {
    NO_CHANGE,
    NEXT_STATE_IN_SEQUENCE,
    ATTACK,
    CANCEL,
}

onready var STATES := {
    State.ATTACK: $States/Attack,
    State.CANCEL: $States/Cancel,
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _indicator_lights: LightningFloorIndicatorLights = $LightningFloorIndicatorLights
onready var _bolts_node: Node2D = $Bolts
onready var _bolts: Array = $Bolts.get_children()
onready var _hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
    assert(not _bolts.empty())
    for bolt in _bolts:
        assert(bolt is LightningBolt)
        bolt.dissipate()
        bolt.pause()

    _current_state_enum = State.CANCEL
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

    stop()

func _process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func start() -> void:
    _change_state({'new_state': State.ATTACK})
    set_process(true)

func stop() -> void:
    _change_state({'new_state': State.CANCEL})
    set_process(false)

func get_indicator_lights() -> LightningFloorIndicatorLights:
    return _indicator_lights

func get_bolts() -> Array:
    return _bolts

func get_bolts_node() -> Node2D:
    return _bolts_node

func get_hitbox_collision_shape() -> CollisionShape2D:
    return _hitbox_collision_shape

func _change_state(new_state_dict: Dictionary) -> void:
    var old_state_enum := _current_state_enum
    var new_state_enum: int = new_state_dict['new_state']

    # Before passing along the new_state_dict to the new state (since we want
    # any additional metadata keys passed too), rename the 'new_state' key to
    # 'previous_state'.
    new_state_dict.erase('new_state')
    new_state_dict['previous_state'] = old_state_enum

    _current_state.exit(self)
    _current_state_enum = new_state_enum
    _current_state = STATES[new_state_enum]
    _current_state.enter(self, new_state_dict)
