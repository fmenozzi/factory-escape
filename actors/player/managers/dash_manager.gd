extends Node2D
class_name DashManager

const SAVE_KEY := 'dash_manager'

# The amount of time to wait after completing a dash before dashing again.
const DASH_COOLDOWN: float = 0.30

var _has_dash := false
var _can_dash := true

onready var _dash_buffer: DashBuffer = $DashBuffer
onready var _dash_cooldown_timer: Timer = $DashCooldown

func _ready() -> void:
    _dash_cooldown_timer.wait_time = DASH_COOLDOWN
    _dash_cooldown_timer.one_shot = true

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'has_dash': _has_dash,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var dash_manager_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('has_dash' in dash_manager_save_data)

    _has_dash = dash_manager_save_data['has_dash']

func has_dash() -> bool:
    return _has_dash

func can_dash() -> bool:
    return _has_dash and _can_dash and get_dash_cooldown_timer().is_stopped()

func consume_dash() -> void:
    _can_dash = false

func reset_dash() -> void:
    _can_dash = true

func can_buffer_dash() -> bool:
    return _dash_buffer.can_buffer_dash()

func get_dash_cooldown_timer() -> Timer:
    return _dash_cooldown_timer

func _on_ability_chosen(chosen_ability: int) -> void:
    assert(chosen_ability in [
        DemoAbility.Ability.DASH,
        DemoAbility.Ability.DOUBLE_JUMP,
        DemoAbility.Ability.GRAPPLE,
        DemoAbility.Ability.WALL_JUMP
    ])

    if chosen_ability == DemoAbility.Ability.DASH:
        _has_dash = true

func _on_dash_acquired(ability: int) -> void:
    assert(ability == Ability.Kind.DASH)

    _has_dash = true
