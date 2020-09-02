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
export(Ability) var ability := Ability.DASH

onready var _icon: Sprite = $Icon
onready var _selectable_area: Area2D = $SelectableArea
onready var _fade_in_out_label: Label = $FadeInOutLabel
onready var _reading_points: Node2D = $WalkToPoints

func _get_configuration_warning() -> String:
    if ability_icon == null:
        return 'Demo ability must have icon texture!'

    return ''

func _ready() -> void:
    assert(ability_icon != null)

    _icon.texture = ability_icon

    _selectable_area.connect('body_entered', self, '_on_player_entered')
    _selectable_area.connect('body_exited', self, '_on_player_exited')

    set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed('player_interact'):
        emit_signal('ability_inspected', self)

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
