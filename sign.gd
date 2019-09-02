extends Area2D

onready var _sprite: Sprite = $Sprite
onready var _tween: Tween = $OutlineTween

const UNHIGHLIGHTED := Color.white
const HIGHLIGHTED := Color(10, 10, 10, 10)

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(self)

    _modulate_color(UNHIGHLIGHTED, HIGHLIGHTED)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(null)

    _modulate_color(HIGHLIGHTED, UNHIGHLIGHTED)

func _modulate_color(old: Color, new: Color) -> void:
    var prop := 'modulate'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    _tween.stop_all()
    _tween.interpolate_property(self, prop, old, new, duration, trans, easing)
    _tween.start()