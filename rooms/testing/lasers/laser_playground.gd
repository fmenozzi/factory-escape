extends Room

onready var _lasers: Array = $Enemies.get_children()

func _draw() -> void:
    for laser in _lasers:
        draw_circle(laser.position + laser._target.position, 2, Color.red)

func _ready() -> void:
    for laser in _lasers:
        laser.shoot()

    update()
