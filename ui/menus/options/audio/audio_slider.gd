extends HBoxContainer

onready var _slider: HSlider = $Container/Slider
onready var _value_label: Label = $Container/Value

func _ready() -> void:
    _slider.connect('value_changed', self, '_on_slider_value_changed')

func _on_slider_value_changed(new_value: float) -> void:
    # Apply padding with spaces.
    _value_label.text = '%2d' % int(new_value)
