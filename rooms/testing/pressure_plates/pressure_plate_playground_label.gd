extends Label

func _ready() -> void:
    var pressure_plate: Node2D = get_parent().get_node('PressurePlate')
    pressure_plate.connect('pressed', self, '_on_pressure_plate_pressed')
    pressure_plate.connect('released', self, '_on_pressure_plate_released')

func _on_pressure_plate_pressed() -> void:
    self.set_text('Plate: Pressed')

func _on_pressure_plate_released() -> void:
    self.set_text('Plate: Released')