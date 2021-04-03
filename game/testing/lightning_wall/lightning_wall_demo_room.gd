extends Room

onready var _lightning_wall_middle: LightningWall = $Hazards/LightningWallMiddle
onready var _lightning_wall_bottom: LightningWall = $Hazards/LightningWallBottom

func _ready() -> void:
    _lightning_wall_middle.resume()
    _lightning_wall_bottom.resume()
