extends Node

onready var player: Player = $World/Player
onready var health_bar: Control = $UILayer/Healthbar

func _ready() -> void:
    player.get_health().connect(
        'health_changed', health_bar, '_on_health_changed')