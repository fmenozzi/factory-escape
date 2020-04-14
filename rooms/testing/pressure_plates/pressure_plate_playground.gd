extends Room

onready var _pressure_plate: Node2D = $PressurePlate
onready var _label: Label = $Label

func _ready() -> void:
    _pressure_plate.connect('pressed', self, '_on_pressure_plate_pressed')
    _pressure_plate.connect('released', self, '_on_pressure_plate_released')

func _on_pressure_plate_pressed() -> void:
    _label.text = 'Plate: Pressed'

func _on_pressure_plate_released() -> void:
    _label.text = 'Plate: Released'
