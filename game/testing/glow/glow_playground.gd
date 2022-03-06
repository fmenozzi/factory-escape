extends RoomFe

export(float) var glow_period := 2.0
export(float, 1.0, 2.0) var max_glow_multiplier := 1.5

onready var _glow_sprite: Sprite = $GlowSprite
onready var _tween: Tween = $GlowTween

var _glow_multiplier := 1.0

func _ready() -> void:
    _tween.repeat = true
    _tween.connect('tween_step', self, '_on_glow_multiplier_changed')
    _tween.interpolate_property(
        self, '_glow_multiplier', 1.0, max_glow_multiplier, glow_period / 2.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.interpolate_property(
        self, '_glow_multiplier', max_glow_multiplier, 1.0, glow_period / 2.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN, glow_period / 2.0)
    _tween.start()

func _on_glow_multiplier_changed(_object, _key, _elapsed, value: float) -> void:
    _glow_sprite.modulate = Color(value, value, value, 1.0)
