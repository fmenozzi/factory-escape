extends Node

# If true, run this game instance "standalone", which means that it doesn't save
# or load any non-options data. This is needed for demo rooms, as otherwise the
# player will be loaded to the wrong location.
export(bool) var run_standalone := true

onready var _player: Player = Util.get_player()
onready var _camera: Camera2D = _player.get_camera()
onready var _pause: Control = $Layers/PauseLayer/Pause
onready var _dialog_box: Control = $Layers/DialogBoxLayer/DialogBox
onready var _health_bar: Control = $Layers/UILayer/HealthBar
onready var _health_pack_bar: Control = $Layers/UILayer/HealthPackBar
onready var _saving_indicator: Control = $Layers/PauseLayer/SavingIndicator
onready var _screen_fadeout: Control = $Layers/ScreenFadeoutLayer/ScreenFadeout
onready var _vignette: Control = $Layers/ScreenSpaceEffectsLayer/Vignette
onready var _player_death_transition: Control = $Layers/ScreenSpaceEffectsLayer/PlayerDeathTransition

func _notification(what: int) -> void:
    match what:
        MainLoop.NOTIFICATION_WM_FOCUS_IN:
            if get_tree().paused:
                MouseCursor.set_mouse_mode(MouseCursor.MouseMode.VISIBLE)
            else:
                MouseCursor.set_mouse_mode(MouseCursor.MouseMode.HIDDEN)

        MainLoop.NOTIFICATION_WM_FOCUS_OUT:
            MouseCursor.set_mouse_mode(MouseCursor.MouseMode.VISIBLE)

func _ready() -> void:
    if not run_standalone:
        # Before loading the game, set the last saved global position and
        # direction to the player's current global position and direction (i.e.
        # as set in the editor for this Game instance). This will be overwritten
        # during load if the player has rested at a lamp in the current save
        # slot, or has at least completed the intro fall sequence.
        _player.save_manager.last_saved_global_position = _player.global_position
        _player.save_manager.last_saved_direction_to_lamp = _player.get_direction()

        # Use slot 1 by default if we don't go through the title screen.
        #
        # Encountering an error here should normally only be possible when
        # skipping the title screen via standalone mode.
        if SaveAndLoad.save_slot == SaveAndLoad.SaveSlot.UNSET:
            SaveAndLoad.save_slot = SaveAndLoad.SaveSlot.SLOT_1
        SaveAndLoad.load_game_and_report_errors()

        # Determine player's starting state.
        if not _player.save_manager.has_completed_intro_fall_sequence:
            # Main UI starts off transparent so that it can fade in after the
            # fall sequence finishes.
            _health_bar.modulate.a = 0
            _health_pack_bar.modulate.a = 0
            _player.connect(
                'player_finished_intro_fall', self, '_on_player_finished_intro_fall')
            _player.change_state({'new_state': Player.State.INTRO_FALL})
        else:
            _player.change_state({'new_state': Player.State.SLEEP})

    # Set the clear color to be the dark blue background color, in order to
    # prevent accidentally seeing untiled areas when doing funky camera stuff.
    # Set it dynamically rather than in project settings so that we don't forget
    # to tile each room as normal when building them, which might otherwise lead
    # to broken navtiles
    VisualServer.set_default_clear_color(Color('#1d212d'))

    MouseCursor.set_mouse_mode(MouseCursor.MouseMode.HIDDEN)

    var player_health := _player.get_health()
    player_health.connect('health_changed', _health_bar, '_on_health_changed')
    player_health.connect('health_changed', _vignette, '_on_health_changed')
    player_health.connect('died', self, '_on_player_died')

    _player.connect('player_hit_hazard', self, '_on_player_hit_hazard')
    _player.connect('player_hit_by_enemy', _dialog_box, '_on_player_hit')
    _player.connect('player_heal_succeeded', self, '_on_player_heal_succeeded')
    _player.connect('player_heal_failed', self, '_on_player_heal_failed')
    _player.connect(
        'player_heal_attempted_no_health_packs', self,
        '_on_player_heal_attempted_no_health_packs')

    var player_health_pack_manager := _player.get_health_pack_manager()
    player_health_pack_manager.connect(
        'health_pack_consumed', self, '_on_health_pack_consumed')

    _health_pack_bar.set_health_packs(
        player_health_pack_manager.num_health_packs())

    for lamp in get_tree().get_nodes_in_group('lamps'):
        lamp.connect('lamp_lit', self, '_on_player_lit_lamp')
        lamp.connect('rested_at_lamp', self, '_on_player_rested_at_lamp')

    for health_pack in get_tree().get_nodes_in_group('health_packs'):
        health_pack.connect('health_pack_taken', self, '_on_health_pack_taken')

    for switch in get_tree().get_nodes_in_group('switches'):
        switch.connect('switch_press_started', self, '_on_player_pressed_switch')

    for buddy in get_tree().get_nodes_in_group('buddy'):
        _dialog_box.connect('dialog_finished', buddy, '_on_dialog_finished')

    Options.connect('options_saved', self, '_on_options_saved')

    _pause.connect('quit_to_main_menu_requested', self, '_on_quit_to_main_menu')
    _pause.connect('quit_to_desktop_requested', self, '_on_quit_to_desktop')

    _set_player_starting_room()

    _set_player_starting_health_and_health_packs()

    _set_player_starting_music()

func _set_player_starting_room() -> void:
    var starting_room: Room = null

    # Get all the rooms from each set of rooms.
    var rooms := $World/Rooms/Prelude.get_children()
    rooms.append_array($World/Rooms/CentralHub.get_children())
    rooms.append_array($World/Rooms/SectorOne.get_children())
    rooms.append_array($World/Rooms/SectorTwo.get_children())
    rooms.append_array($World/Rooms/SectorThree.get_children())
    rooms.append_array($World/Rooms/SectorFour.get_children())
    rooms.append_array($World/Rooms/SectorFive.get_children())

    if not run_standalone and not _player.save_manager.has_completed_intro_fall_sequence:
        # If we're running a "real" game (i.e. not a standalone demo) and we
        # haven't completed the intro fall sequence (i.e. we're starting up the
        # game for the first time), assume that the current room is the first
        # room in the Rooms node. This is important because the player starts
        # out outside the room boundaries in the intro fall sequence, which
        # would result in null values for player.curr_room and player.prev_room
        # if we simply loop over the existing rooms and check which one contains
        # the player.
        assert(not rooms.empty())
        starting_room = rooms[0]
    else:
        # Simply determine which room actually contains the player.
        for room in rooms:
            if room.contains(_player):
                starting_room = room

    assert(starting_room != null)

    _player.curr_room = starting_room
    _player.prev_room = starting_room
    _player.get_camera().fit_camera_limits_to_room(starting_room)

func _set_player_starting_health_and_health_packs() -> void:
    if run_standalone:
        return

    var psm: PlayerSaveManager = _player.save_manager
    if not psm.has_completed_intro_fall_sequence or \
       (not psm.has_rested_at_any_lamp and not psm.has_completed_central_hub_fall_sequence):
        _player.get_health().set_starting_health()
        _player.get_health_pack_manager().set_starting_health_packs()

func _set_player_starting_music() -> void:
    MusicPlayer.get_player(MusicPlayer.Music.FACTORY_BACKGROUND).set_max_volume_db(-8.0)
    if _player.curr_room.has_node('Lamp'):
        MusicPlayer.play(MusicPlayer.Music.LAMP_ROOM)
        MusicPlayer.stop(MusicPlayer.Music.FACTORY_BACKGROUND)
    else:
        yield(get_tree().create_timer(1.0), 'timeout')
        MusicPlayer.fade_in(MusicPlayer.Music.WORLD_BASE, 6.0)

func _maybe_save_game() -> void:
    if not run_standalone:
        SaveAndLoad.save_game_and_report_errors()

    # Options are saved regardless of whether we're running in standalone mode.
    Options.save_options_and_report_errors()

func _reset_world() -> void:
    for node in get_tree().get_nodes_in_group('lamp_reset'):
        node.lamp_reset()

func _on_player_finished_intro_fall() -> void:
    _health_bar.fade_in()
    _health_pack_bar.fade_in()

func _on_player_died() -> void:
    _player.set_process_unhandled_input(false)

    # Make player invincible for duration of death transition so that they don't
    # trigger an infinite loop by continuously taking contact damage while
    # standing still during death animation.
    _player.get_health().set_status(Health.Status.INVINCIBLE)

    _player.get_sound_manager().play(PlayerSoundManager.Sounds.DIE)

    Screenshake.start(
        Screenshake.Duration.LONG,
        Screenshake.Amplitude.MEDIUM,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.STRONG, 1.0, Rumble.Priority.HIGH)

    # Hide all health-related UI elements.
    _health_bar.hide()
    _health_pack_bar.hide()

    # Start player death sequence.
    _player.change_state({'new_state': Player.State.DIE})
    yield(_player.current_state, 'sequence_finished')

    # Start the player death transition effect.
    _player_death_transition.start_player_death_transition(_player)
    yield(_player_death_transition, 'player_death_transition_finished')

    # Fade to black with the screen fadeout node. The screen is already black as
    # a result of the death transition effect, but the screen fadeout node is in
    # a higher layer than the death transition effect, so we fade to black here
    # to make all the transitions look smoother. This has the added benefit of
    # allowing us to use the time to fade to black to act as a timer for how
    # long the screen should remain black before fading back in.
    _screen_fadeout.fade_to_black(2.0)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Now that the screen is black, we can reset the death transition effect
    # without having to worry about weird graphical artifacts.
    _player_death_transition.reset()

    # We can also reset/reattach the player camera, which only matters if the
    # player dies during a cutscene in which a different camera has been marked
    # as current (or if the camera was detached).
    var player_camera := _player.get_camera()
    player_camera.make_current()
    player_camera.reattach()

    _reset_world()

    MusicPlayer.stop(MusicPlayer.Music.ARENA)
    if _player.curr_room.has_node('Lamp'):
        MusicPlayer.play(MusicPlayer.Music.LAMP_ROOM)
    else:
        MusicPlayer.play(MusicPlayer.Music.WORLD_BASE)

    var lamp := _player.get_nearby_lamp()
    if lamp != null:
        lamp.fade_out_label()
    _player.change_state({'new_state': Player.State.SLEEP})

    # Spin saving indicator for two seconds to let player notice it.
    _saving_indicator.start_spinning_for(2.0)
    _maybe_save_game()
    if _saving_indicator.is_spinning():
        yield(_saving_indicator, 'spinning_finished')

    # Show all health-related UI elements
    _health_bar.show()
    _health_pack_bar.show()

    Screenshake.stop()
    Rumble.stop()

    _player.get_health().set_status(Health.Status.NONE)

    _screen_fadeout.fade_from_black(2.0)
    yield(_screen_fadeout, 'fade_from_black_finished')

    _player.set_process_unhandled_input(true)

func _on_player_hit_hazard() -> void:
    var fade_duration := 0.4
    var fade_delay := 0.0
    var fade_music := false

    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
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

    fade_delay = 0.25
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)
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
    yield(_player, 'player_reached_walk_to_point')

    _player.save_manager.last_saved_global_position = closest_rest_point.global_position
    _player.save_manager.last_saved_direction_to_lamp = Util.direction(_player, lamp)
    _player.save_manager.has_rested_at_any_lamp = true

    _player.get_health_pack_manager().update_saved_num_health_packs()

    _reset_world()

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

    var health_pack_manager := _player.get_health_pack_manager()

    # Add health pack to health pack manager. If player is already carrying the
    # max number of health packs, treat this health pack as a heal and heal the
    # player to full health.
    var old_health_packs := health_pack_manager.num_health_packs()
    health_pack_manager.add_health_pack()
    var new_health_packs := health_pack_manager.num_health_packs()
    if old_health_packs == new_health_packs:
        _player.get_health().heal_to_full()
    _health_pack_bar.set_health_packs(new_health_packs)

func _on_player_pressed_switch(switch: Switch) -> void:
    switch.set_process_unhandled_input(false)
    _player.set_process_unhandled_input(false)

    # Fade out label text.
    switch.fade_out_label()

    # Start the ACTIVATE_SWITCH state sequence.
    _player.change_state({
        'new_state': Player.State.ACTIVATE_SWITCH,
        'stopping_point': switch.get_closest_walk_to_point(),
        'object_to_face': switch,
    })
    yield(_player.current_state, 'sequence_finished')

    switch.reset_state_to(Switch.State.PRESSED)

    # Only after all the animations and everything are finished do we emit the
    # 'switch_press_finished' signal (which is what things that are attached to
    # the switch will be listening for).
    switch.emit_signal('switch_press_finished')

    _player.set_process_unhandled_input(true)
    switch.set_process_unhandled_input(true)

func _on_health_pack_consumed() -> void:
    _health_pack_bar.set_health_packs(
        _player.get_health_pack_manager().num_health_packs())

func _on_player_heal_succeeded() -> void:
    _player.get_health().heal_to_full()
    _player.get_sound_manager().play(PlayerSoundManager.Sounds.HEAL_SUCCEEDED)

func _on_player_heal_failed() -> void:
    _player.get_sound_manager().play(PlayerSoundManager.Sounds.HEAL_FAILED)

    _health_bar.flash()

func _on_player_heal_attempted_no_health_packs() -> void:
    _player.get_sound_manager().play(
        PlayerSoundManager.Sounds.HEAL_ATTEMPTED_NO_HEALTH_PACKS)

    _health_pack_bar.flash()

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
