extends Button
class_name CycleOptionsButton

signal option_changed

enum Option {
    NEXT = 1,
    PREVIOUS = -1
}

onready var _arrow_container: HBoxContainer = $HBoxContainer

var _options := []
var _current_option_index := 0

func _ready() -> void:
    self.connect('pressed', self, '_cycle_option', [Option.NEXT])
    self.connect('focus_entered', _arrow_container, 'show')
    self.connect('focus_exited', _arrow_container, 'hide')

func set_options(options: Array) -> void:
    assert(not options.empty())
    for option in options:
        assert(option is String and not option.empty())

    _options = options.duplicate(true)

func select_next_option() -> void:
    _cycle_option(Option.NEXT)

func select_previous_option() -> void:
    _cycle_option(Option.PREVIOUS)

func get_current_option() -> String:
    assert(0 <= _current_option_index and _current_option_index < _options.size())

    return _options[_current_option_index]

func set_current_option(idx: int) -> void:
    assert(0 <= idx and idx < _options.size())

    _current_option_index = idx
    self.text = _options[_current_option_index]
    emit_signal('option_changed')

func _cycle_option(option: int) -> void:
    assert(option in [Option.NEXT, Option.PREVIOUS])

    set_current_option(wrapi(_current_option_index + option, 0, _options.size()))
