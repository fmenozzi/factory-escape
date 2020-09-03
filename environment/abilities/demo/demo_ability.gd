extends Node2D
class_name DemoAbility

# Signal emitted when the player reads the demo ability object, though whether
# they ultimately decide to accept it is decided later.
signal ability_inspected(demo_ability_object)

enum Ability {
    DASH,
    DOUBLE_JUMP,
    GRAPPLE,
    WALL_JUMP,
}

export(Texture) var ability_icon: Texture = null
export(Texture) var ability_foreground_glow_texture: Texture = null
export(Ability) var ability := Ability.DASH

onready var _sprites: Node2D = $Sprites
onready var _icon: Sprite = $Sprites/Icon
onready var _background_glow_sprite: Sprite = $Sprites/BackgroundGlow
onready var _foreground_glow_sprite: Sprite = $Sprites/ForegroundGlow
onready var _selectable_area: Area2D = $SelectableArea
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _reading_points: Node2D = $WalkToPoints
onready var _glow_tween: Tween = $GlowTween
onready var _float_tween: Tween = $FloatTween
onready var _fade_out_tween: Tween = $FadeOutTween

func _get_configuration_warning() -> String:
    if ability_icon == null:
        return 'Demo ability must have icon texture!'

    if ability_foreground_glow_texture == null:
        return 'Demo ability must have foreground glow texture!'

    return ''

func _ready() -> void:
    assert(ability_icon != null)
    assert(ability_foreground_glow_texture != null)

    _icon.texture = ability_icon
    _foreground_glow_sprite.texture = ability_foreground_glow_texture

    _selectable_area.connect('body_entered', self, '_on_player_entered')
    _selectable_area.connect('body_exited', self, '_on_player_exited')

    set_process_unhandled_input(false)

    _start_glow_tween()
    _start_float_tween()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        emit_signal('ability_inspected', self)

func _start_glow_tween() -> void:
    _glow_tween.repeat = true

    var prop := 'modulate'
    var old := Color(1, 1, 1, 1)
    var new := Color(1.2, 1.2, 1.2, 1)
    var duration := 1.0
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN
    var delay := duration

    _glow_tween.remove_all()

    # Background glow sprite.
    _glow_tween.interpolate_property(
        _background_glow_sprite, prop, old, new, duration, trans, easing)
    _glow_tween.interpolate_property(
        _background_glow_sprite, prop, new, old, duration, trans, easing, delay)

    # Foreground glow sprite.
    _glow_tween.interpolate_property(
        _foreground_glow_sprite, prop, old, new, duration, trans, easing)
    _glow_tween.interpolate_property(
        _foreground_glow_sprite, prop, new, old, duration, trans, easing, delay)

    _glow_tween.start()

func _start_float_tween() -> void:
    _float_tween.repeat = true

    var prop := 'position:y'
    var old := 0
    var new := -2
    var duration := 1.0
    var trans := Tween.TRANS_QUAD
    var easing := Tween.EASE_IN_OUT
    var delay := duration

    _float_tween.remove_all()

    _float_tween.interpolate_property(
        _sprites, prop, old, new, duration, trans, easing)
    _float_tween.interpolate_property(
        _sprites, prop, new, old, duration, trans, easing, delay)

    _float_tween.start()

func get_closest_reading_point() -> Position2D:
    return _reading_points.get_closest_point()

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _fade_in_out_label.fade_in()

    set_process_unhandled_input(true)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    _fade_in_out_label.fade_out()

    set_process_unhandled_input(false)

func _on_ability_chosen(ability_object: DemoAbility) -> void:
    assert(ability_object != null)

    # Regardless of whether this ability was chosen, make it non-interactable.
    _selectable_area.disconnect('body_entered', self, '_on_player_entered')
    _selectable_area.disconnect('body_exited', self, '_on_player_exited')
    set_process_unhandled_input(false)

    var prop := 'modulate:a'
    var old := 1.0
    var new := 0.0
    var duration := 1.0
    var trans := Tween.TRANS_LINEAR
    var easing := Tween.EASE_IN
    var delay := 0.0 if ability_object != self else 2.0

    # Fade out the ability object. The selected abillity object will fade out on
    # a delay, while the others will fade out immediately.
    _fade_out_tween.remove_all()
    _fade_out_tween.interpolate_property(
        self, prop, old, new, duration, trans, easing, delay)
    _fade_out_tween.start()
