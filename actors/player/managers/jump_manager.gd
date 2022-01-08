extends Node2D
class_name JumpManager

const SAVE_KEY := 'jump_manager'

enum State {
    NOT_JUMPED,
    JUMPED,
    DOUBLE_JUMPED,
}
var _state: int = State.NOT_JUMPED

var _has_double_jump := false

onready var _jump_buffer: JumpBuffer = $JumpBuffer

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'has_double_jump': _has_double_jump,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var jump_manager_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('has_double_jump' in jump_manager_save_data)

    _has_double_jump = jump_manager_save_data['has_double_jump']

func can_jump() -> bool:
    assert(_state in [State.NOT_JUMPED, State.JUMPED, State.DOUBLE_JUMPED])

    match _state:
        State.NOT_JUMPED:
            # If we haven't jumped, we can jump.
            return true

        State.JUMPED:
            # If we've already jumped, we can only jump again if we have the
            # double jump.
            return _has_double_jump

        _:
            # If we've already double-jumped, we can't jump anymore.
            return false

func consume_jump() -> void:
    assert(_state in [State.NOT_JUMPED, State.JUMPED, State.DOUBLE_JUMPED])

    match _state:
        State.NOT_JUMPED:
            _state = State.JUMPED

        State.JUMPED:
            if _has_double_jump:
                _state = State.DOUBLE_JUMPED


func reset_jump() -> void:
    _state = State.NOT_JUMPED

func can_buffer_jump() -> bool:
    return _jump_buffer.can_buffer_jump()

func acquire_double_jump() -> void:
    _has_double_jump = true

func _on_ability_chosen(chosen_ability: int) -> void:
    assert(chosen_ability in [
        DemoAbility.Ability.DASH,
        DemoAbility.Ability.DOUBLE_JUMP,
        DemoAbility.Ability.GRAPPLE,
        DemoAbility.Ability.WALL_JUMP
    ])

    if chosen_ability == DemoAbility.Ability.DOUBLE_JUMP:
        _has_double_jump = true
