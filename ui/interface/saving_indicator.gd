extends Control

signal one_spin_completed

export(float) var duration := 0.25

onready var _upper_left: Polygon2D = $UpperLeft
onready var _upper_right: Polygon2D = $UpperRight
onready var _lower_right: Polygon2D = $LowerRight
onready var _lower_left: Polygon2D = $LowerLeft

onready var _tween: Tween = $AlphaTween

var _is_spinning := false

func start_spinning() -> void:
    self.modulate.a = 1.0
    _is_spinning = true
    while true:
        if not _is_spinning:
            return
        _spin_once()
        yield(self, 'one_spin_completed')

func stop_spinning() -> void:
    self.modulate.a = 0.0
    _is_spinning = false

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