extends Area2D

export(Array, String) var dialog

onready var _sprite: Sprite = $Sprite
onready var _outline_tween: Tween = $Sprite/OutlineTween
onready var _fade_in_out_label: Label = $FadeInOutLabel

const SIGN_UNHIGHLIGHTED := Color.white
const SIGN_HIGHLIGHTED := Color(10, 10, 10, 10)

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(self)

    _modulate_sign_color(SIGN_UNHIGHLIGHTED, SIGN_HIGHLIGHTED)
    label_fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(null)

    _modulate_sign_color(SIGN_HIGHLIGHTED, SIGN_UNHIGHLIGHTED)
    label_fade_out()

# TODO: For some reason, when tweening just the sprite's modulate instead of the
# entire Sign scene's modulate, the tweening becomes slightly out-of-sync with
# the fade label's tween visually-speaking.
func _modulate_sign_color(old: Color, new: Color) -> void:
    var prop := 'modulate'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    var tween := _outline_tween
    tween.stop_all()
    tween.interpolate_property(_sprite, prop, old, new, duration, trans, easing)
    tween.start()

func label_fade_in() -> void:
    _fade_in_out_label.fade_in()

func label_fade_out() -> void:
    _fade_in_out_label.fade_out()