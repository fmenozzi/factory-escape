extends Node2D
class_name SinkingPlatform

enum State {
    IDLE_TOP,
    IDLE_BOTTOM,
    GOING_DOWN,
    GOING_UP,
}
var _state: int = State.IDLE_TOP

const SPEED_DOWN := 2.0 * Util.TILE_SIZE
const SPEED_UP := 2.0 * SPEED_DOWN

onready var _platform: KinematicBody2D = $Platform
onready var _animation_player: AnimationPlayer = $Platform/AnimationPlayer
onready var _trigger_area: Area2D = $Platform/TriggerArea
onready var _destination: Position2D = $Destination

func _physics_process(delta: float) -> void:
    match _state:
        State.IDLE_TOP:
            if _player_on_platform():
                _animation_player.play('move')
                _state = State.GOING_DOWN

        State.IDLE_BOTTOM:
            if not _player_on_platform():
                _animation_player.play('move')
                _state = State.GOING_UP

        State.GOING_DOWN:
            _platform.position.y += SPEED_DOWN * delta
            if _platform.position.y >= _destination.position.y:
                _platform.position.y = _destination.position.y
                _animation_player.stop()
                _state = State.IDLE_BOTTOM

            if not _player_on_platform():
                _state = State.GOING_UP

        State.GOING_UP:
            _platform.position.y -= SPEED_UP * delta
            if _platform.position.y <= 0:
                _platform.position.y = 0
                _animation_player.stop()
                _state = State.IDLE_TOP

            if _player_on_platform():
                _state = State.GOING_DOWN

func pause() -> void:
    set_physics_process(false)
func resume() -> void:
    set_physics_process(true)

func _player_on_platform() -> bool:
    var player: Player = Util.get_player()
    for body in _trigger_area.get_overlapping_bodies():
        if body == player:
            return true
    return false
