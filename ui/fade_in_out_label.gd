extends Label

export(float) var duration := 0.25

const LABEL_VISIBLE := Color(1, 1, 1, 1)
const LABEL_NOT_VISIBLE := Color(1, 1, 1, 0)

onready var _tween: Tween = $FadeTween

func _modulate_label_visibility(old: Color, new: Color) -> void:
    var prop := 'modulate'
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    _tween.stop_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

func set_text(new_text: String) -> void:
    self.text = new_text

func fade_in() -> void:
    _modulate_label_visibility(self.modulate, LABEL_VISIBLE)

func fade_out() -> void:
    _modulate_label_visibility(self.modulate, LABEL_NOT_VISIBLE)
