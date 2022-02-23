extends Room

onready var _closing_door: StaticBody2D = $ClosingDoorSectorFive
onready var _pause_point: Position2D = $PausePoint
onready var _stopping_point: Position2D = $StoppingPoint

func _ready() -> void:
    get_closing_door().set_opened()

func get_closing_door() -> StaticBody2D:
    return _closing_door

func get_pause_point() -> Position2D:
    return _pause_point

func get_stopping_point() -> Position2D:
    return _stopping_point
