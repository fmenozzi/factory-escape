extends Node

onready var _player: Player = Util.get_player()
onready var _camera: Camera2D = _player.get_camera()
onready var _rooms: Array = $World/Rooms.get_children()
onready var _health_bar: Control = $Layers/UILayer/Healthbar
onready var _saving_indicator: Node2D = $Layers/UILayer/SavingIndicator
onready var _screen_fadeout: Control = $Layers/ScreenFadeoutLayer/ScreenFadeout

func _ready() -> void:
    var player_health := _player.get_health()
    player_health.connect('health_changed', _health_bar, '_on_health_changed')
    player_health.connect('died', self, '_on_player_died')

    _player.connect('player_hit_hazard', self, '_on_player_hit_hazard')

    for lamp in get_tree().get_nodes_in_group('lamps'):
        lamp.connect('lamp_lit', self, '_on_player_lit_lamp')
        lamp.connect('rested_at_lamp', self, '_on_player_rested_at_lamp')

    # Find the player's current room.
    for room in _rooms:
        if room.contains(_player):
            _player.curr_room = room
            _player.prev_room = room
            _player.get_camera().fit_camera_limits_to_room(room)

# TODO: See if we can find a more efficient way of doing this that doesn't
#       involve iterating over every room in every frame. Maybe some kind of
#       map or otherwise more advanced data structure?
#
#       e.g. maybe you can use thin, one-way collision boxes at each room
#       entrance to signal room changes.
func _process(delta: float) -> void:
    for room in _rooms:
        # Transition to room once we enter a new one.
        if room != _player.curr_room and room.contains(_player):
            _player.prev_room = _player.curr_room
            _player.curr_room = room

            # Pause processing on the old room, transition to the new one, and
            # then begin processing on the new room once the transition is
            # complete.
            _player.prev_room.pause()
            _camera.transition(_player.prev_room, _player.curr_room)
            yield(_camera, 'transition_completed')
            _player.curr_room.resume()

func _on_player_died() -> void:
    print('YOU DIED')

func _on_player_hit_hazard() -> void:
    Screenshake.start(
        Screenshake.Duration.MEDIUM,
        Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)

    Rumble.start(Rumble.Type.STRONG, 0.25, Rumble.Priority.HIGH)

    _screen_fadeout.fade_out()
    yield(_screen_fadeout, 'fade_out_completed')

    # Reset player at the last hazard checkpoint. Set the player's direction to
    # be the direction from the checkpoint to the player's impact point with the
    # hazard.
    var hazard_checkpoint := _player.get_hazard_checkpoint()
    _player.set_direction(Util.direction(hazard_checkpoint, _player))
    _player.set_global_position(hazard_checkpoint.get_global_position())

    # Kind of a hack, but we want to make sure we're not still in the HAZARD_HIT
    # animation while the screen is fading back in, so set the player sprite to
    # be the first frame of the 'hazard_recover' animation.
    _player.get_node('Sprite').frame = 72

    var fade_in_delay := 0.25
    _screen_fadeout.fade_in(fade_in_delay)
    yield(_screen_fadeout, 'fade_in_completed')

    # Play the 'hazard recover' animation once the screen fades back in. Note
    # that the HAZARD_HIT state itself (which the player would be in at this
    # point) has no way of transitioning to a new state, which means we need to
    # do so here. This is done to prevent the player from jumping and being in
    # the air while the HAZARD_RECOVER animation plays.
    _player.change_state({'new_state': Player.State.HAZARD_RECOVER})

func _on_player_lit_lamp(lamp: Area2D) -> void:
    lamp.set_process_unhandled_input(false)
    _player.set_process_unhandled_input(false)

    # Fade out label text so that it can be changed and faded back
    # in.
    lamp.fade_out_label()

    _player.change_state({
        'new_state': Player.State.WALK_TO_POINT,
        'stopping_point': lamp.get_closest_light_walk_to_point(),
    })
    yield(_player, 'player_walked_to_point')
    yield(get_tree(), 'physics_frame')

    # Ensure player is facing lamp.
    _player.set_direction(Util.direction(_player, lamp))

    # Play light_lamp animation and wait for that to finish before
    # the lamp actually lights.
    #
    # TODO: This might be better served as its own state.
    var player_animation_player := _player.get_animation_player()
    player_animation_player.play('light_lamp')
    yield(player_animation_player, 'animation_finished')
    player_animation_player.play('idle')

    lamp.light()

    _player.set_process_unhandled_input(true)
    lamp.set_process_unhandled_input(true)

func _on_player_rested_at_lamp(lamp: Area2D) -> void:
    lamp.set_process_unhandled_input(false)
    _player.set_process_unhandled_input(false)

    _player.change_state({
        'new_state': Player.State.WALK_TO_POINT,
        'stopping_point': lamp.get_closest_rest_walk_to_point(),
    })
    yield(_player, 'player_walked_to_point')
    yield(get_tree(), 'physics_frame')

    _player.change_state({
        'new_state': Player.State.REST,
        'lamp': lamp,
    })

    _player.get_health().heal_to_full()

    # For now, simulate time spent saving game to disk by yielding for two
    # seconds as we start up the saving indicator. Once we actually have a save
    # system in place, it's likely that there will still be a "minimum time"
    # spent spinning, even if the actual save takes less time. This allows the
    # player to notice the saving indicator.
    _saving_indicator.show()
    yield(get_tree().create_timer(2.0), 'timeout')
    _saving_indicator.hide()

    lamp.set_process_unhandled_input(true)
    _player.set_process_unhandled_input(true)

    print('Game Saved')
