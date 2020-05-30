extends Area2D

export(Array, String) var dialog

const FlashShader := preload('res://shared/shaders/flash.shader')
const UNHIGHLIGHTED_LERP_AMOUNT := 0.0
const HIGHLIGHTED_LERP_AMOUNT := 1.0

onready var _sprite: Sprite = $Sprite
onready var _outline_tween: Tween = $Sprite/OutlineTween
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _reading_points: Node2D = $WalkToPoints

var _shader_manager: ShaderManager = ShaderManager.new()

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

    _shader_manager.add_shader(FlashShader, _sprite)
    _shader_manager.set_shader_param('flash_color', Color.white)

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(self)

    _modulate_sign_color(UNHIGHLIGHTED_LERP_AMOUNT, HIGHLIGHTED_LERP_AMOUNT)
    label_fade_in()

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    player.set_nearby_sign(null)

    _modulate_sign_color(HIGHLIGHTED_LERP_AMOUNT, UNHIGHLIGHTED_LERP_AMOUNT)
    label_fade_out()

# Manually use flash shader to highlight and unhighlight the sign sprite. The
# FlashManager's current API does not make this convenient, as it was originally
# designed for multiple flashes over a certain time period, and not sustaining
# a single flash color indefinitely. This also fixes the previous issue of the
# sign highlighting tween being slightly out-of-sync with the fade label's
# tween, though I'm not sure why.
func _modulate_sign_color(old: float, new: float) -> void:
    var material := _shader_manager.get_shader_material()
    var param := 'shader_param/lerp_amount'
    var duration := 0.25
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN

    var tween := _outline_tween
    tween.stop_all()
    tween.interpolate_property(
        material, param, old, new, duration, trans, easing)
    tween.start()

func get_closest_reading_point() -> Position2D:
    return _reading_points.get_closest_point()

func label_fade_in() -> void:
    _fade_in_out_label.fade_in()

func label_fade_out() -> void:
    _fade_in_out_label.fade_out()
