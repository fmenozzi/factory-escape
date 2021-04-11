extends Node2D
class_name Arena

onready var _trigger: Area2D = $Trigger

func _ready() -> void:
    _trigger.connect('body_entered', self, '_start_arena')

    set_process(false)

func _process(delta: float) -> void:
    pass

func _start_arena(player: Player) -> void:
    if not player:
        return

    set_process(true)
