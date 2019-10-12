extends Node

onready var player: Player = $World/Player
onready var health_bar: Control = $UILayer/Healthbar
onready var screen_fadeout: Control = $ScreenFadeoutLayer/ScreenFadeout

func _ready() -> void:
    var player_health := player.get_health()
    player_health.connect('health_changed', health_bar, '_on_health_changed')
    player_health.connect('died', self, '_on_player_died')

    player.connect('player_hit_hazard', self, '_on_player_hit_hazard')

func _on_player_died() -> void:
    print('YOU DIED')

func _on_player_hit_hazard() -> void:
    screen_fadeout.fade_out()
    yield(screen_fadeout, 'fade_out_completed')

    player.set_global_position(player.get_hazard_checkpoint())

    var fade_in_delay := 0.25
    screen_fadeout.fade_in(fade_in_delay)
    yield(screen_fadeout, 'fade_in_completed')