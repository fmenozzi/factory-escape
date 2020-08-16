extends Control

signal player_death_transition_finished

onready var _color_rect: ColorRect = $ColorRect
onready var _tween: Tween = $EffectRadiusTween

func reset() -> void:
    _color_rect.get_material().set_shader_param('effect_radius_uv', Vector2.ZERO)

func start_player_death_transition(player: Player) -> void:
    assert(player != null)

    reset()

    var mat: ShaderMaterial = _color_rect.get_material()

    mat.set_shader_param('player_center_uv', _get_player_center_uv(player))

    var prop := 'shader_param/effect_radius_uv'
    var old := 0.0
    var new := 2.0 # Greater than one to account for player near edge of screen
    var duration := 0.5
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN
    _tween.remove_all()
    _tween.interpolate_property(mat, prop, old, new, duration, trans, easing)
    _tween.start()
    yield(_tween, 'tween_all_completed')

    emit_signal('player_death_transition_finished')

func _get_player_center_uv(player: Player) -> Vector2:
    var player_position_screen_space := player.get_global_transform_with_canvas().get_origin()
    var player_center_screen_space := player_position_screen_space + Vector2(0, -8)
    return player_center_screen_space / Util.get_ingame_resolution()
