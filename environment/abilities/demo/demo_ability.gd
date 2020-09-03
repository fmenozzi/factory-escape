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

onready var _icon: Sprite = $Icon
onready var _background_glow_sprite: Sprite = $BackgroundGlow
onready var _foreground_glow_sprite: Sprite = $ForegroundGlow
onready var _selectable_area: Area2D = $SelectableArea
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _reading_points: Node2D = $WalkToPoints
onready var _glow_tween: Tween = $GlowTween

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

    if ability_object != self:
        hide()
    else:
        pass
