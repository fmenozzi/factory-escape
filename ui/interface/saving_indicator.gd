extends Control

signal one_spin_completed

export(float) var duration := 0.25

onready var _upper_left: Polygon2D = $UpperLeft
onready var _upper_right: Polygon2D = $UpperRight
onready var _lower_right: Polygon2D = $LowerRight
onready var _lower_left: Polygon2D = $LowerLeft

onready var _tween: Tween = $AlphaTween

func _ready() -> void:
    hide()
    _start_spinning()

func show() -> void:
    self.visible = true

func hide() -> void:
    self.visible = false

func _start_spinning() -> void:
    while true:
        _spin_once()
        yield(self, 'one_spin_completed')

func _spin_once() -> void:
    _tween.remove_all()

    _setup_tween_fade_in(_lower_left)
    _setup_tween_fade_out(_upper_left)
    _tween.start()
    yield(_tween, 'tween_all_completed')

    _setup_tween_fade_in(_upper_left)
    _setup_tween_fade_out(_upper_right)
    _tween.start()
    yield(_tween, 'tween_all_completed')

    _setup_tween_fade_in(_upper_right)
    _setup_tween_fade_out(_lower_right)
    _tween.start()
    yield(_tween, 'tween_all_completed')

    _setup_tween_fade_in(_lower_right)
    _setup_tween_fade_out(_lower_left)
    _tween.start()
    yield(_tween, 'tween_all_completed')

    emit_signal('one_spin_completed')

func _setup_tween_fade_in(tri: Polygon2D) -> void:
    _tween.interpolate_property(
        tri, 'color:a', 0.0, 1.0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)

func _setup_tween_fade_out(tri: Polygon2D) -> void:
    _tween.interpolate_property(
        tri, 'color:a', 1.0, 0.0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)