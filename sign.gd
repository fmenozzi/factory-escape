extends Area2D

export(Array, String) var dialog

onready var _sprite: Sprite = $Sprite
onready var _outline_tween: Tween = $Sprite/OutlineTween

onready var _label: Label = $Label
onready var _label_tween: Tween = $Label/LabelTween

const SIGN_UNHIGHLIGHTED := Color.white
const SIGN_HIGHLIGHTED := Color(10, 10, 10, 10)

const LABEL_VISIBLE := Color(1, 1, 1, 1)
const LABEL_NOT_VISIBLE := Color(1, 1, 1, 0)

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(self)

    _modulate_sign_color(SIGN_UNHIGHLIGHTED, SIGN_HIGHLIGHTED)
    _modulate_label_visibility(LABEL_NOT_VISIBLE, LABEL_VISIBLE)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(null)

    _modulate_sign_color(SIGN_HIGHLIGHTED, SIGN_UNHIGHLIGHTED)
    _modulate_label_visibility(LABEL_VISIBLE, LABEL_NOT_VISIBLE)

func _modulate_sign_color(old: Color, new: Color) -> void:
    var prop := 'modulate'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    var tween := _outline_tween
    tween.stop_all()
    tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    tween.start()

func _modulate_label_visibility(old: Color, new: Color) -> void:
    var prop := 'modulate'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    var tween := _label_tween
    tween.stop_all()
    tween.interpolate_property(_label, prop, old, new, duration, trans, easing)
    tween.start()