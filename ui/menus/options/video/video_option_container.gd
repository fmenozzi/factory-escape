extends HBoxContainer

signal option_changed

export(Array) var options
export(String) var default_option

onready var _label: Label = $Label
onready var _cycle_options_button: CycleOptionsButton = $CycleOptionsButton

func _ready() -> void:
    _cycle_options_button.set_options(options)
    _cycle_options_button.set_current_option(options.find(default_option))

    assert(default_option in options)
    reset_to_default()

    _cycle_options_button.connect('option_changed', self, '_on_item_selected')

func get_selected_option_name() -> String:
    return _cycle_options_button.get_current_option()

func select_option(option_name: String) -> void:
    assert(option_name in options)

    _cycle_options_button.set_current_option(options.find(option_name))

func reset_to_default() -> void:
    select_option(default_option)

func _on_item_selected() -> void:
    emit_signal('option_changed')
