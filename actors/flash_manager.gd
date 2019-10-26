tool
extends Node

signal flashing_finished

export(NodePath) var sprite_path = ""
export(float) var total_duration := 2.0
export(float) var single_flash_duration := 0.075
export(Color) var flash_color := Color.white

onready var _timer: Timer = $Timer
onready var _tween: Tween = $Tween

func _get_configuration_warning() -> String:
    if sprite_path == "":
        return "Please specify the sprite to flash."
    return ""

func _ready() -> void:
    # Setup flash duration timer.
    _timer.one_shot = true
    _timer.wait_time = total_duration
    _timer.connect('timeout', self, '_on_flashing_timeout')

    # Get the sprite to flash.
    assert sprite_path != ""
    var sprite: Sprite = get_node(sprite_path)

    # Need to modulate past 1 in order to flash white.
    if flash_color == Color.white:
        flash_color = Color(10, 10, 10, 1)

    # Setup flash tween.
    var prop := 'modulate'
    var old := Color(1, 1, 1, 1)
    var new := flash_color
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN
    var delay := single_flash_duration
    _tween.interpolate_property(
        sprite, prop, old, new, single_flash_duration, trans, easing)
    _tween.interpolate_property(
        sprite, prop, new, old, single_flash_duration, trans, easing, delay)

func start_flashing() -> void:
    _timer.start()
    _tween.resume_all()
func stop_flashing() -> void:
    _tween.reset_all()
    _tween.stop_all()

func pause_timer() -> void:
    _timer.paused = true
func resume_timer() -> void:
    _timer.paused = false

func _on_flashing_timeout() -> void:
    stop_flashing()
    emit_signal('flashing_finished')