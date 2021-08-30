extends Node2D
class_name SinkingPlatform

enum State {
    NO_CHANGE,
    IDLE_TOP,
    IDLE_BOTTOM,
    PAUSE_BEFORE_GOING_UP,
    SHAKE,
    GOING_DOWN,
    GOING_UP,
}

onready var STATES := {
    State.IDLE_TOP:              $States/IdleTop,
    State.IDLE_BOTTOM:           $States/IdleBottom,
    State.PAUSE_BEFORE_GOING_UP: $States/PauseBeforeGoingUp,
    State.SHAKE:                 $States/Shake,
    State.GOING_DOWN:            $States/GoingDown,
    State.GOING_UP:              $States/GoingUp
}

var _current_state: Node = null
var _current_state_enum: int = -1

onready var _platform: KinematicBody2D = $Platform
onready var _sprite: Sprite = $Platform/Sprite
onready var _animation_player: AnimationPlayer = $Platform/AnimationPlayer
onready var _trigger_area: Area2D = $Platform/TriggerArea
onready var _destination: Position2D = $Destination

onready var _original_sprite_position: Vector2 = _sprite.position

func _ready() -> void:
    _current_state_enum = State.IDLE_TOP
    _current_state = STATES[_current_state_enum]
    _change_state({'new_state': _current_state_enum})

func _physics_process(delta: float) -> void:
    var new_state_dict = _current_state.update(self, delta)
    if new_state_dict['new_state'] != State.NO_CHANGE:
        _change_state(new_state_dict)

func get_animation_player() -> AnimationPlayer:
    return _animation_player

func get_platform() -> KinematicBody2D:
    return _platform

func get_destination() -> Position2D:
    return _destination

func pause() -> void:
    set_physics_process(false)
func resume() -> void:
    set_physics_process(true)

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass

func shake_once(damping: float = 1.0) -> void:
    _sprite.position = _original_sprite_position + Vector2(
        damping * rand_range(-1.0, 1.0),
        damping * rand_range(-1.0, 1.0))

func reset_sprite_position() -> void:
    _sprite.position = _original_sprite_position

func player_on_platform() -> bool:
    var player: Player = Util.get_player()
    for body in _trigger_area.get_overlapping_bodies():
        if body == player:
            return true
    return false

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
