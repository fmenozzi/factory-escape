extends HBoxContainer
class_name AudioSlider

signal value_changed

onready var _cycle_options_button: CycleOptionsButton = $CycleOptionsButton

func _ready() -> void:
    _cycle_options_button.set_options(
        ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'])
    _cycle_options_button.set_current_option(10) # Index corresponding to '10'

    _cycle_options_button.connect(
        'option_changed', self, 'emit_signal', ['value_changed'])

func get_value() -> int:
    return int(_cycle_options_button.get_current_option())

func set_value(new_value: int) -> void:
    # new_value already conveniently corresponds to its own index.
    _cycle_options_button.set_current_option(new_value)

func max_value() -> int:
    return 10
