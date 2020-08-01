extends Node

# If true, run this game instance "standalone", which means that it doesn't save
# or load any non-options data. This is needed for demo rooms, as otherwise the
# player will be loaded to the wrong location.
export(bool) var run_standalone := true

onready var _player: Player = Util.get_player()
onready var _camera: Camera2D = _player.get_camera()
onready var _rooms: Array = $World/Rooms.get_children()
onready var _pause: Control = $Layers/PauseLayer/Pause
onready var _health_bar: Control = $Layers/UILayer/Healthbar
onready var _health_pack_bar: Control = $Layers/UILayer/HealthPackBar
onready var _saving_indicator: Control = $Layers/UILayer/SavingIndicator
onready var _screen_fadeout: Control = $Layers/ScreenFadeoutLayer/ScreenFadeout
onready var _vignette: Control = $Layers/ScreenSpaceEffectsLayer/Vignette

func _ready() -> void:
    if not run_standalone:
        # Use slot 1 by default if we don't go through the title screen.
        if SaveAndLoad.save_slot == SaveAndLoad.SaveSlot.UNSET:
            SaveAndLoad.save_slot = SaveAndLoad.SaveSlot.SLOT_1
        SaveAndLoad.load_game()

    var player_health := _player.get_health()
    player_health.connect('health_changed', _health_bar, '_on_health_changed')
    player_health.connect('health_changed', _vignette, '_on_health_changed')
    player_health.connect('died', self, '_on_player_died')

    _player.connect('player_hit_hazard', self, '_on_player_hit_hazard')
    _player.connect('player_healed', self, '_on_player_healed')

    _player.get_health_pack_manager().connect(
        'health_pack_consumed', self, '_on_health_pack_consumed')

    for lamp in get_tree().get_nodes_in_group('lamps'):
        lamp.connect('lamp_lit', self, '_on_player_lit_lamp')
        lamp.connect('rested_at_lamp', self, '_on_player_rested_at_lamp')

    for health_pack in get_tree().get_nodes_in_group('health_packs'):
        health_pack.connect('health_pack_taken', self, '_on_health_pack_taken')

    Options.connect('options_saved', self, '_on_options_saved')

    _pause.connect('quit_to_main_menu_requested', self, '_on_quit_to_main_menu')
    _pause.connect('quit_to_desktop_requested', self, '_on_quit_to_desktop')

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

func _maybe_save_game() -> void:
    if not run_standalone:
        SaveAndLoad.save_game()

func _on_player_died() -> void:
    print('YOU DIED')

func _on_player_hit_hazard() -> void:
    var fade_duration := 0.4

    _screen_fadeout.fade_to_black(fade_duration)
    yield(_screen_fadeout, 'fade_to_black_finished')

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

    var fade_delay := 0.25
    _screen_fadeout.fade_from_black(fade_duration, fade_delay)
    yield(_screen_fadeout, 'fade_from_black_finished')

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

    # Start the LIGHT_LAMP state sequence.
    _player.change_state({
        'new_state': Player.State.LIGHT_LAMP,
        'stopping_point': lamp.get_closest_light_walk_to_point(),
        'object_to_face': lamp,
    })
    yield(_player.current_state, 'sequence_finished')

    # Wait until the animation starts before continuing. This helps prevent it
    # from being played twice if the player spams player_interact.
    lamp.light()
    yield(lamp, 'lit_animation_started')

    _player.set_process_unhandled_input(true)
    lamp.set_process_unhandled_input(true)

func _on_player_rested_at_lamp(lamp: Area2D) -> void:
    lamp.set_process_unhandled_input(false)
    _player.set_process_unhandled_input(false)

    var closest_rest_point: Position2D = lamp.get_closest_rest_walk_to_point()

    # Start the REST_AT_LAMP sequence.
    _player.change_state({
        'new_state': Player.State.REST_AT_LAMP,
        'stopping_point': closest_rest_point,
        'object_to_face': lamp,
        'lamp': lamp,
    })

    _player.get_health().heal_to_full()
    _player.last_saved_global_position = closest_rest_point.global_position
    _player.last_saved_direction_to_lamp = Util.direction(_player, lamp)

    # Spin saving indicator for two seconds to let player notice it.
    _saving_indicator.start_spinning_for(2.0)
    _maybe_save_game()
    if _saving_indicator.is_spinning():
        yield(_saving_indicator, 'spinning_finished')

    lamp.set_process_unhandled_input(true)
    _player.set_process_unhandled_input(true)

func _on_health_pack_taken(health_pack: Node2D) -> void:
    _player.change_state({
        'new_state': Player.State.TAKE_HEALTH_PACK,
        'object_to_face': health_pack,
    })
    _player.get_health().heal_to_full()

    var health_pack_manager := _player.get_health_pack_manager()
    health_pack_manager.add_health_pack()
    _health_pack_bar.set_health_packs(health_pack_manager.num_health_packs())

func _on_health_pack_consumed() -> void:
    _health_pack_bar.set_health_packs(
        _player.get_health_pack_manager().num_health_packs())

func _on_player_healed() -> void:
    _player.get_health().heal_to_full()

func _on_options_saved() -> void:
    if _saving_indicator.is_spinning():
        return

    _saving_indicator.start_spinning_for(1.0)

func _on_quit_to_main_menu() -> void:
    var fade_duration := 2.0
    _saving_indicator.start_spinning_for(fade_duration)
    _maybe_save_game()

    SceneChanger.change_scene_to(Preloads.TitleScreen, fade_duration)

func _on_quit_to_desktop() -> void:
    _saving_indicator.start_spinning_for(0.0)
    _maybe_save_game()

    get_tree().quit()
