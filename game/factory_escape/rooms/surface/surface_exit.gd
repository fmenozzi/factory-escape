extends Room

onready var _closing_door: StaticBody2D = $ClosingDoorSectorFive
onready var _stopping_point: Position2D = $StoppingPoint

func _ready() -> void:
    get_closing_door().set_opened()

func get_closing_door() -> StaticBody2D:
    return _closing_door

func get_stopping_point() -> Position2D:
    return _stopping_point
