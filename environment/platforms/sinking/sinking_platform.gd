extends Node2D
class_name SinkingPlatform

enum State {
    IDLE_TOP,
    IDLE_BOTTOM,
    PAUSE_BEFORE_GOING_UP,
    SHAKE,
    GOING_DOWN,
    GOING_UP,
}
var _state: int = State.IDLE_TOP

const SPEED_DOWN := 2.0 * Util.TILE_SIZE
const SPEED_UP := 2.0 * SPEED_DOWN

const TOTAL_PAUSE_DURATION := 1.0
const TOTAL_SHAKE_DURATION := 0.25

var _pause_duration := 0.0
var _shake_duration := 0.0

onready var _platform: KinematicBody2D = $Platform
onready var _sprite: Sprite = $Platform/Sprite
onready var _animation_player: AnimationPlayer = $Platform/AnimationPlayer
onready var _trigger_area: Area2D = $Platform/TriggerArea
onready var _destination: Position2D = $Destination

onready var _original_sprite_position: Vector2 = _sprite.position

func _physics_process(delta: float) -> void:
    match _state:
        State.IDLE_TOP:
            if _player_on_platform():
                _animation_player.play('move')
                _state = State.SHAKE

        State.IDLE_BOTTOM:
            if not _player_on_platform():
                _pause_duration = 0.0
                _animation_player.stop()
                _state = State.PAUSE_BEFORE_GOING_UP

        State.PAUSE_BEFORE_GOING_UP:
            _pause_duration += delta
            if _pause_duration >= TOTAL_PAUSE_DURATION:
                _pause_duration = 0
                _animation_player.play('move')
                if _player_on_platform():
                    _state = State.SHAKE
                else:
                    _state = State.GOING_UP

        State.SHAKE:
            _shake_duration += delta
            var damping := ease(
                (TOTAL_SHAKE_DURATION - _shake_duration) / TOTAL_SHAKE_DURATION,
                1.0)
            _shake_once(damping)
            if _shake_duration >= TOTAL_SHAKE_DURATION:
                _shake_duration = 0
                _reset_sprite_position()
                _animation_player.play('move')
                if _player_on_platform():
                    _state = State.GOING_DOWN
                else:
                    _state = State.GOING_UP

        State.GOING_DOWN:
            _platform.position.y += SPEED_DOWN * delta
            if _platform.position.y >= _destination.position.y:
                _platform.position.y = _destination.position.y
                _animation_player.stop()
                _state = State.IDLE_BOTTOM

            if not _player_on_platform():
                _pause_duration = 0.0
                _animation_player.stop()
                _state = State.PAUSE_BEFORE_GOING_UP

        State.GOING_UP:
            _platform.position.y -= SPEED_UP * delta
            if _platform.position.y <= 0:
                _platform.position.y = 0
                _animation_player.stop()
                _state = State.IDLE_TOP

            if _player_on_platform():
                _state = State.SHAKE

func pause() -> void:
    set_physics_process(false)
func resume() -> void:
    set_physics_process(true)

func _shake_once(damping: float = 1.0) -> void:
    _sprite.position = _original_sprite_position + Vector2(
        damping * rand_range(-1.0, 1.0),
        damping * rand_range(-1.0, 1.0))

func _reset_sprite_position() -> void:
    _sprite.position = _original_sprite_position

func _player_on_platform() -> bool:
    var player: Player = Util.get_player()
    for body in _trigger_area.get_overlapping_bodies():
        if body == player:
            return true
    return false
