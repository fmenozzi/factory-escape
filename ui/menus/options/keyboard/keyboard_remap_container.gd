extends HBoxContainer

export(String) var label := ''

onready var _label: Label = $Label
onready var _remap_button: Button = $KeyboardRemapButton

func _ready() -> void:
    _label.text = label

    _remap_button.connect('remap_started', self, '_on_remap_started')
    _remap_button.connect('remap_finished', self, '_on_remap_finished')

func _on_remap_started() -> void:
    _label.text = 'Press new...'

func _on_remap_finished() -> void:
    _label.text = label
    _remap_button.grab_focus()
