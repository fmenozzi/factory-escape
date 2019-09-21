extends Sprite

onready var _tween: Tween = $AlphaTween

func _ready() -> void:
    # Make sure we draw the player over the dash echo.
    self.show_behind_parent = true

    var prop := 'modulate'
    var old := Color(1, 1, 1, 0.5) # Semi-transparent
    var new := Color(1, 1, 1, 0.0) # Transparent
    var duration := 0.5
    var trans := Tween.TRANS_SINE
    var easing := Tween.EASE_OUT

    _tween.stop_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()

    # Free the dash echo once it's become fully transparent.
    yield(_tween, 'tween_completed')
    queue_free()