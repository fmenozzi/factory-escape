extends Room

onready var _lightning_wall_with_switch: Node2D = $Hazards/LightningWallWithSwitch

func _ready() -> void:
    _lightning_wall_with_switch.resume()
