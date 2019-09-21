extends Node

onready var player: Player = $World/Player
onready var health_bar: Control = $UILayer/Healthbar

func _ready() -> void:
    var player_health := player.get_health()
    player_health.connect('health_changed', health_bar, '_on_health_changed')
    player_health.connect('died', self, '_on_player_died')

func _on_player_died() -> void:
    print('YOU DIED')