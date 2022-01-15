extends Control

signal spinning_started
signal spinning_finished

const TRANSPARENT := 0.0
const OPAQUE := 1.0

const UpperLeftSectorFive := preload('res://ui/interface/saving_indicator/textures/saving-indicator-upper-left-sector-5.png')
const UpperRightSectorFive := preload('res://ui/interface/saving_indicator/textures/saving-indicator-upper-right-sector-5.png')
const LowerRightSectorFive := preload('res://ui/interface/saving_indicator/textures/saving-indicator-lower-right-sector-5.png')
const LowerLeftSectorFive := preload('res://ui/interface/saving_indicator/textures/saving-indicator-lower-left-sector-5.png')

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _sprites: Node2D = $Sprites
onready var _upper_left: Sprite = $Sprites/UpperLeft
onready var _upper_right: Sprite = $Sprites/UpperRight
onready var _lower_right: Sprite = $Sprites/LowerRight
onready var _lower_left: Sprite = $Sprites/LowerLeft
onready var _tween: Tween = $Sprites/VisibilityTween
onready var _timer: Timer = $Timer

func _ready() -> void:
    _timer.one_shot = true
    _timer.connect('timeout', self, '_on_timeout')

    _sprites.modulate.a = 0.0

func start_spinning_for(duration: float) -> void:
    _animation_player.play('spin')

    if duration > 0.0:
        _timer.wait_time = duration
        _timer.start()

    _fade_spinner(TRANSPARENT, OPAQUE)

    emit_signal('spinning_started')

func stop_spinning() -> void:
    _timer.stop()

    _fade_spinner(OPAQUE, TRANSPARENT)

    yield(_tween, 'tween_all_completed')
    _animation_player.stop(true)

    emit_signal('spinning_finished')

func is_spinning() -> bool:
    return _animation_player.is_playing()

func switch_to_sector_5_textures() -> void:
    _upper_left.texture = UpperLeftSectorFive
    _upper_right.texture = UpperRightSectorFive
    _lower_right.texture = LowerRightSectorFive
    _lower_left.texture = LowerLeftSectorFive

func _fade_spinner(old: float, new: float) -> void:
    var duration := 0.25

    _tween.remove_all()
    _tween.interpolate_property(
        _sprites, 'modulate:a', old, new, duration, Tween.TRANS_QUAD,
        Tween.EASE_IN)
    _tween.start()

func _on_timeout() -> void:
    stop_spinning()
