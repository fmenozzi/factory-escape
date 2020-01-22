extends Node

onready var player: Player = Util.get_player()
onready var health_bar: Control = $UILayer/Healthbar
onready var saving_indicator: Node2D = $UILayer/SavingIndicator
onready var screen_fadeout: Control = $ScreenFadeoutLayer/ScreenFadeout

func _ready() -> void:
    var player_health := player.get_health()
    player_health.connect('health_changed', health_bar, '_on_health_changed')
    player_health.connect('died', self, '_on_player_died')

    player.connect('player_hit_hazard', self, '_on_player_hit_hazard')

    for lamp in get_tree().get_nodes_in_group('lamps'):
        lamp.connect('rested_at_lamp', self, '_on_player_rested_at_lamp')

func _on_player_died() -> void:
    print('YOU DIED')

func _on_player_hit_hazard() -> void:
    screen_fadeout.fade_out()
    yield(screen_fadeout, 'fade_out_completed')

    # Reset player at the last hazard checkpoint. Set the player's direction to
    # be the direction from the checkpoint to the player's impact point with the
    # hazard.
    var hazard_checkpoint := player.get_hazard_checkpoint()
    player.set_direction(Util.direction(hazard_checkpoint, player))
    player.set_global_position(hazard_checkpoint.get_global_position())

    # Kind of a hack, but we want to make sure we're not still in the HAZARD_HIT
    # animation while the screen is fading back in, so set the player sprite to
    # be the first frame of the 'hazard_recover' animation.
    player.get_node('Sprite').frame = 72

    var fade_in_delay := 0.25
    screen_fadeout.fade_in(fade_in_delay)
    yield(screen_fadeout, 'fade_in_completed')

    # Play the 'hazard recover' animation once the screen fades back in. Note
    # that the HAZARD_HIT state itself (which the player would be in at this
    # point) has no way of transitioning to a new state, which means we need to
    # do so here. This is done to prevent the player from jumping and being in
    # the air while the HAZARD_RECOVER animation plays.
    player.change_state({'new_state': Player.State.HAZARD_RECOVER})

func _on_player_rested_at_lamp(lamp: Area2D) -> void:
    print('Game Saved')

    player.get_health().heal_to_full()

    player.change_state({
        'new_state': Player.State.REST,
        'lamp': lamp,
    })

    # For now, simulate time spent saving game to disk by yielding for two
    # seconds as we start up the saving indicator. Once we actually have a save
    # system in place, it's likely that there will still be a "minimum time"
    # spent spinning, even if the actual save takes less time. This allows the
    # player to notice the saving indicator.
    saving_indicator.show()
    yield(get_tree().create_timer(2.0), 'timeout')
    saving_indicator.hide()