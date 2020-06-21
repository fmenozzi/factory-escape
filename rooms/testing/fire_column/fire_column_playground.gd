extends Room

onready var _fire_column: FireColumn = $Hazards/FireColumn
onready var _fire_column_timer: Timer = $FireColumnTimer

func _ready() -> void:
    _fire_column_timer.one_shot = false
    _fire_column_timer.wait_time = 3.0
    _fire_column_timer.connect('timeout', self, '_fire')
    _fire_column_timer.start()

    _fire()

func _fire() -> void:
    _fire_column.fire()
