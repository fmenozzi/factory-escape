extends HBoxContainer

signal option_changed

export(Array) var options
export(String) var default_option

onready var _label: Label = $Label
onready var _option_button: OptionButton = $OptionButton

func _ready() -> void:
    var idx := 0
    for option in options:
        _option_button.add_item(option, idx)
        idx += 1

    assert(default_option in options)
    reset_to_default()

    _option_button.connect('item_selected', self, '_on_item_selected')

func is_being_set() -> bool:
    return _option_button.pressed

func get_selected_option_name() -> String:
    return options[_option_button.selected]

func select_option(option_name: String) -> void:
    assert(option_name in options)

    _option_button.select(options.find(option_name))

func reset_to_default() -> void:
    select_option(default_option)

func _on_item_selected(idx: int) -> void:
    emit_signal('option_changed')
