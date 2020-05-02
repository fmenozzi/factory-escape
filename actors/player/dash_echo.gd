extends Sprite

export(float) var glow_multiplier := 1.0

onready var _tween: Tween = $AlphaTween

func _ready() -> void:
    var prop := 'modulate'
    var old := Color(glow_multiplier, glow_multiplier, glow_multiplier, 1.0)
    var new := Color(glow_multiplier, glow_multiplier, glow_multiplier, 0.0)
    var duration := 0.5
    var trans := Tween.TRANS_SINE
    var easing := Tween.EASE_OUT

    _tween.stop_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

    # Free the dash echo once it's become fully transparent.
    yield(_tween, 'tween_completed')
    queue_free()
