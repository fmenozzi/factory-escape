extends "res://game/game_interface.gd"

onready var _cargo_lift: RoomFe = $World/Rooms/Prelude/CargoLift
onready var _central_hub: RoomFe = $World/Rooms/CentralHub/CentralHub
onready var _central_hub_save_manager: CentralHubSaveManager = $World/Rooms/CentralHub/CentralHub/SaveManager
onready var _central_hub_camera_focus_point: CameraFocusPoint = $World/Rooms/CentralHub/CentralHub/CameraFocusPoint
onready var _warden_spawn_point: Position2D = $World/Rooms/CentralHub/CentralHub/BossFight/WardenSpawnPoint
onready var _lightning_floor: LightningFloor = $World/Rooms/CentralHub/CentralHub/BossFight/LightningFloor
onready var _projectile_spawners: Array = $World/Rooms/CentralHub/CentralHub/BossFight/ProjectileSpawners.get_children()
onready var _ability_acquired_message: Control = $Layers/UILayer/AbilityAcquiredMessage
onready var _dash_tutorial_trigger: Area2D = $World/Rooms/SectorOne/SectorOne_17/TutorialMessageTrigger
onready var _wall_jump_tutorial_trigger: Area2D = $World/Rooms/SectorTwo/SectorTwo_13/TutorialMessageTrigger
onready var _double_jump_tutorial_trigger: Area2D = $World/Rooms/SectorThree/SectorThree_11/TutorialMessageTrigger
onready var _grapple_tutorial_trigger: Area2D = $World/Rooms/SectorFour/SectorFour_13/TutorialMessageTrigger
onready var _central_hub_suspend_point: Position2D = $World/Rooms/CentralHub/CentralHub/PlayerSuspensionPoint
onready var _central_lock_cutscene_camera: Camera2D = $World/Rooms/CentralHub/CentralHub/CentralLockCutsceneCamera
onready var _central_lock: CentralLock = $World/Rooms/CentralHub/CentralHub/CentralLock
onready var _suspend_point_post_warden: Position2D = $World/Rooms/CentralHub/CentralHub/PlayerSuspensionPointPostWarden
onready var _central_lock_save_manager: CentralLockSaveManager = $World/Rooms/CentralHub/CentralHub/CentralLock/SaveManager
onready var _sector_five_lift: RoomFe = $World/Rooms/SectorFive/SectorFiveLift
onready var _sector_five_lift_suspend_point: Position2D = $World/Rooms/SectorFive/SectorFiveLift/PlayerSuspensionPoint
onready var _sector_five_lift_cutscene_camera: Camera2D = $World/Rooms/SectorFive/SectorFiveLift/CutsceneCamera
onready var _arena_elevator_start: Node2D = $World/Rooms/SectorFive/SectorFive_20/ArenaElevator
onready var _arena_elevator_start_switch: Switch = $World/Rooms/SectorFive/SectorFive_20/ArenaElevator/Platform/SwitchSectorFive
onready var _elevator_arena_room: RoomFe = $World/Rooms/SectorFive/SectorFive_21
onready var _elevator_arena_room_arena: ElevatorArena = $World/Rooms/SectorFive/SectorFive_21/ElevatorArena
onready var _elevator_arena_room_elevator: Node2D = $World/Rooms/SectorFive/SectorFive_21/ArenaElevator
onready var _arena_elevator_end: Node2D = $World/Rooms/SectorFive/SectorFive_22/ArenaElevator
onready var _arena_elevator_end_room: RoomFe = $World/Rooms/SectorFive/SectorFive_22
onready var _surface_exit: RoomFe = $World/Rooms/Surface/SurfaceExit

func _ready() -> void:
    _cargo_lift.connect('player_entered_cargo_lift', self, '_on_player_entered_cargo_lift')
    _central_hub.connect(
        'player_entered_central_hub_shaft', self, '_on_player_entered_central_hub_shaft')

    for ability in get_tree().get_nodes_in_group('abilities'):
        ability.connect('ability_acquired', self, '_on_ability_acquired')

    for central_lock_switch in get_tree().get_nodes_in_group('central_lock_switches'):
        central_lock_switch.connect('unlocked', self, '_on_central_lock_switch_pressed')

    _central_hub.connect('boss_fight_triggered', self, '_on_boss_fight_triggered')

    _arena_elevator_start_switch.connect(
        'switch_press_finished', self, '_on_arena_elevator_switch_pressed')

    _elevator_arena_room_arena.connect(
        'elevator_arena_finished', self, '_on_elevator_arena_finished')

    _surface_exit.connect('entered_room', self, '_on_player_reached_surface')

func _connect_warden_signals(warden: Warden) -> void:
    warden.connect('lightning_floor_activated', _lightning_floor, 'start')
    warden.connect('projectiles_spawn_activated', self, '_on_projectile_spawn_activated')
    warden.connect('crashed_into_wall', _player, '_on_warden_crashed_into_wall')
    warden.connect('died', self, '_on_warden_died')

func _on_projectile_spawn_activated() -> void:
    for spawner in _projectile_spawners:
        spawner.shoot_homing_projectile(
            spawner.global_position.direction_to(_player.get_center()))

func _on_player_entered_cargo_lift() -> void:
    # Move player to suspension point.
    _player.change_state({'new_state': Player.State.SUSPENDED})
    _player.global_position = _central_hub_suspend_point.global_position
    yield(get_tree(), 'physics_frame')

    # Fade to black.
    var fade_duration := 2.0
    var fade_delay := 0.0
    var fade_music := true
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Disable room transitions for central hub. Make sure we also update the
    # camera limits accordingly.
    _central_hub.set_enable_room_transitions(false)
    _player.get_camera().fit_camera_limits_to_room(_central_hub)

    # Switch to cutscene camera.
    _central_lock_cutscene_camera.make_current()

    # Start the fall sequence.
    _player.change_state({'new_state': Player.State.CENTRAL_HUB_FALL})

    # Fade from black.
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)

    if _player.current_state_enum == Player.State.CENTRAL_HUB_FALL:
        yield(_player.current_state, 'sequence_finished')

    # Switch back to player camera.
    _player.get_camera().make_current()

    # Re-enable room transitions for central hub.
    _central_hub.set_enable_room_transitions(true)

    # Reset previous/current room so that next room transition works properly.
    _player.prev_room = _central_hub
    _player.curr_room = _central_hub

func _on_ability_acquired(ability: Ability) -> void:
    # Acquire ability and save game immediately (in case player quits out during
    # cutscene).
    _player.save_manager.last_saved_global_position = _player.global_position
    _player.save_manager.last_saved_direction_to_lamp = _player.get_direction()
    match ability.ability:
        Ability.Kind.DASH:
            _player.get_dash_manager().acquire_dash()
        Ability.Kind.WALL_JUMP:
            _player.get_wall_jump_manager().acquire_wall_jump()
        Ability.Kind.DOUBLE_JUMP:
            _player.get_jump_manager().acquire_double_jump()
        Ability.Kind.GRAPPLE:
            _player.get_grapple_manager().acquire_grapple()
    ability.mark_as_acquired()
    _player.get_health_pack_manager().update_saved_num_health_packs()
    _maybe_save_game()

    # Pause player/ability processing.
    ability.set_process_unhandled_input(false)
    _player.set_process_unhandled_input(false)

    # Start ability acquired sequence.
    _player.change_state({
        'new_state': Player.State.ACQUIRE_ABILITY,
        'stopping_point': ability.get_closest_walk_to_point(),
        'object_to_face': ability,
        'ability': ability,
    })
    yield(_player.current_state, 'sequence_finished')

    # Hide ability visuals.
    ability.hide()

    # Quickly flash white and fade back more slowly.
    var fade_duration := 0.1
    _screen_fadeout.fade_to_white(fade_duration)
    yield(_screen_fadeout, 'fade_to_white_finished')
    fade_duration = 1.0
    _screen_fadeout.fade_from_white(fade_duration)
    yield(_screen_fadeout, 'fade_from_white_finished')

    # Show ability acquired message.
    var message := ''
    match ability.ability:
        Ability.Kind.DASH:
            message = 'Dash Acquired'
        Ability.Kind.WALL_JUMP:
            message = 'Wall Jump Acquired'
        Ability.Kind.DOUBLE_JUMP:
            message = 'Double Jump Acquired'
        Ability.Kind.GRAPPLE:
            message = 'Grapple Acquired'
    _ability_acquired_message.show_message(message)
    yield(_ability_acquired_message, 'message_shown')

    # Fade back to actual music.
    var music_fade_duration := 1.0
    MusicPlayer.cross_fade(
        MusicPlayer.Music.ABILITY_IDLE_LOOP, _player.curr_room.get_section_track(), music_fade_duration)

    # Activate tutorial trigger.
    match ability.ability:
        Ability.Kind.DASH:
            _dash_tutorial_trigger.set_is_active(true)
        Ability.Kind.WALL_JUMP:
            _wall_jump_tutorial_trigger.set_is_active(true)
        Ability.Kind.DOUBLE_JUMP:
            _double_jump_tutorial_trigger.set_is_active(true)
        Ability.Kind.GRAPPLE:
            _grapple_tutorial_trigger.set_is_active(true)

    # Resume player processing.
    _player.set_process_unhandled_input(true)

    # Free ability once the acquired sound is finished playing.
    yield(ability, 'finished_playing_acquired_sound')
    ability.queue_free()

func _on_central_lock_switch_pressed(sector_number: int) -> void:
    assert(sector_number in [1, 2, 3, 4])

    # Pause player processing.
    _player.set_process_unhandled_input(false)
    _player.set_physics_process(false)

    # Fade to black.
    var fade_duration := 2.0
    var fade_delay := 0.0
    var fade_music := false
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Switch to cutscene camera.
    _central_lock_cutscene_camera.make_current()

    # Turn off HUD elements.
    _health_bar.modulate.a = 0
    _health_pack_bar.modulate.a = 0

    # Fade back from black. Cross fade to anticipation track during fade.
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)
    MusicPlayer.cross_fade(
        _player.curr_room.get_section_track(), MusicPlayer.Music.ANTICIPATION, fade_duration/2.0)
    yield(_screen_fadeout, 'fade_from_black_finished')

    # Turn on corresponding light. If other lights are already playing their
    # pulse animation, wait until the right moment in their animation to begin
    # the animation sequence for turning on this light. This helps to ensure
    # that the pulses of all four lights are synchronized.
    if _central_lock.lights_already_pulsing():
        yield(_central_lock, 'ready_to_turn_on_new_light')
    _central_lock.turn_on_light(sector_number)

    # Check here whether we've unlocked all four sectors in order to progress to
    # the warden fight.
    if _central_lock_save_manager.sector_one_unlocked and \
       _central_lock_save_manager.sector_two_unlocked and \
       _central_lock_save_manager.sector_three_unlocked and \
       _central_lock_save_manager.sector_four_unlocked:
        _central_hub_save_manager.warden_fight_state = CentralHubSaveManager.WardenFightState.FIGHT
        _central_hub.set_enable_boss_fight_triggers(true)

    # Wait for the light to turn on + one pulse.
    yield(get_tree().create_timer(3.0), 'timeout')

    if _central_lock.all_lights_pulsing():
        # Once all four sector lights are on, turn on the central light and open
        # the door.
        yield(_central_lock, 'ready_to_turn_on_new_light')
        _central_lock.turn_on_light(CentralLock.LockLight.CENTRAL)
        yield(get_tree().create_timer(3.0), 'timeout')
        _central_lock.get_closing_door().open()
        Screenshake.start(
            Screenshake.Duration.LONG, Screenshake.Amplitude.VERY_SMALL,
            Screenshake.Priority.HIGH)
        Rumble.start(Rumble.Type.WEAK, 0.5, Rumble.Priority.HIGH)
        yield(get_tree().create_timer(2.0), 'timeout')
    else:
        # Wait for an additional pulse.
        yield(get_tree().create_timer(2.0), 'timeout')

    # Fade back to black. Cross fade back to section track after fade to black.
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')
    MusicPlayer.cross_fade(
        MusicPlayer.Music.ANTICIPATION, _player.curr_room.get_section_track(), fade_duration/2.0)

    # Switch back to player camera.
    _player.get_camera().make_current()

    # Turn HUD elements back on.
    _health_bar.modulate.a = 1
    _health_pack_bar.modulate.a = 1

    # Fade back from black.
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_from_black_finished')

    # Resume player processing.
    _player.set_process_unhandled_input(true)
    _player.set_physics_process(true)

func _on_boss_fight_triggered() -> void:
    # Pause player processing and immediately ground the player.
    _player.change_state({'new_state': Player.State.WARDEN_INTRO_CUTSCENE})
    yield(_player.current_state, 'sequence_finished')
    _player.set_process_unhandled_input(false)
    _player.set_physics_process(false)

    # Enable boss fight walls so player can't leave.
    _central_hub.set_enable_boss_fight_walls(true)

    # Disable camera focus point to keep the camera fixed.
    _central_hub_camera_focus_point.set_active(false)

    # Wait a bit and then close the doors.
    yield(get_tree().create_timer(0.35), 'timeout')
    _central_lock.get_closing_door().close()
    Screenshake.start(
        Screenshake.Duration.LONG, Screenshake.Amplitude.VERY_SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.5, Rumble.Priority.HIGH)
    yield(Screenshake, 'stopped_shaking')

    # Wait a bit, then two big shakes, timed to the light pulse.
    yield(get_tree().create_timer(1.0), 'timeout')
    yield(_central_lock, 'ready_to_turn_on_new_light')
    MusicPlayer.fade_out(_central_hub.get_room_track(), 0.5)
    _central_hub.get_offscreen_rumble_audio_player().play(0.3)
    Screenshake.start(
        Screenshake.Duration.LONG, Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.75, Rumble.Priority.HIGH)
    yield(get_tree().create_timer(2.0), 'timeout')
    Screenshake.start(
        Screenshake.Duration.LONG, Screenshake.Amplitude.SMALL,
        Screenshake.Priority.HIGH)
    Rumble.start(Rumble.Type.WEAK, 0.75, Rumble.Priority.HIGH)
    yield(get_tree().create_timer(1.5), 'timeout')

    # Spawn warden and wait for intro sequence to finish. Start playing music
    # once it lands on the floor.
    var warden: Warden = Preloads.Warden.instance()
    _central_hub.add_child(warden)
    warden.global_position = _warden_spawn_point.global_position
    warden.set_direction(Util.direction(warden, _player))
    _connect_warden_signals(warden)
    yield(warden, 'intro_sequence_landed_on_floor')
    var warden_fight_start: AudioStreamPlayer = MusicPlayer.get_player(MusicPlayer.Music.WARDEN_FIGHT_START)
    warden_fight_start.play()
    warden_fight_start.connect('finished', MusicPlayer, 'play', [MusicPlayer.Music.WARDEN_FIGHT])
    yield(warden, 'intro_sequence_finished')

    # Resume player processing.
    _player.set_process_unhandled_input(true)
    _player.set_physics_process(true)

func _on_warden_died(warden: Warden) -> void:
    # Pause player processing and switch to IDLE state.
    _player.set_process_unhandled_input(false)
    _player.set_physics_process(false)
    _player.change_state({'new_state': Player.State.IDLE})

    # Switch warden to IDLE state temporarily so that it doesn't keep attacking
    # during the fadeout.
    warden._change_state({'new_state': Warden.State.IDLE})

    # Flash white on the screen to hide the fact that we may need to move some
    # stuff around a bit.
    var fade_duration := 0.1
    _screen_fadeout.fade_to_white(fade_duration)
    yield(_screen_fadeout, 'fade_to_white_finished')

    # Stop the lightning floor in case it was active at time of death.
    _lightning_floor.stop()

    # Remove the projectiles and spawners.
    for spawner in _projectile_spawners:
        spawner.queue_free()
    for enemy in _central_hub.get_node('Enemies').get_children():
        if enemy is Warden:
            continue
        enemy.queue_free()

    # Save warden fight state.
    _central_hub._save_manager.warden_fight_state = CentralHubSaveManager.WardenFightState.POST_FIGHT

    # Ensure warden is grounded. It's not important to ensure that it is not
    # over the door, since it will explode and die before the door opens.
    var warden_ground_detector := warden.get_ground_detector()
    warden_ground_detector.force_raycast_update()
    warden.global_position = warden_ground_detector.get_collision_point()

    # Ensure player is grounded and not over the door.
    _player.set_physics_process(true)
    _player.change_state({
        'new_state': Player.State.POST_WARDEN_ADJUSTMENTS,
        'door_area': _central_hub.get_door_area(),
        'warden': warden,
    })
    yield(_player.current_state, 'sequence_finished')
    _player.set_physics_process(false)

    # Fade it back in now that we're done.
    _screen_fadeout.fade_from_white(fade_duration)
    yield(_screen_fadeout, 'fade_from_white_finished')

    # Save game.
    _player.get_health_pack_manager().update_saved_num_health_packs()
    _maybe_save_game()

    # Play end music and fade back into section track.
    MusicPlayer.fade_out(MusicPlayer.Music.WARDEN_FIGHT, 0.5)
    var warden_fight_end: AudioStreamPlayer = MusicPlayer.get_player(MusicPlayer.Music.WARDEN_FIGHT_END)
    warden_fight_end.play()
    warden_fight_end.connect('finished', MusicPlayer, 'play', [_central_hub.get_section_track()])

    # Boom.
    warden._change_state({'new_state': Warden.State.DIE})
    yield(warden._current_state, 'sequence_finished')
    warden.queue_free()

    # Re-enable camera focus point.
    _central_hub_camera_focus_point.set_active(true)

    # Disable boss walls/triggers.
    _central_hub.set_enable_boss_fight_triggers(false)
    _central_hub.set_enable_boss_fight_walls(false)

    # Wait a bit and then open the door.
    yield(get_tree().create_timer(1.0), 'timeout')
    _central_lock.get_closing_door().open()
    yield(_central_lock.get_closing_door(), 'door_opened')

    # Resume player processing.
    _player.set_process_unhandled_input(true)
    _player.set_physics_process(true)

func _on_player_entered_central_hub_shaft() -> void:
    # Move player to first suspension point, which is within the camera focus
    # point's trigger area. This is to prevent the camera from behaving weirdly
    # when the player is moved to a suspension point outside the camera focus\
    # point trigger area before we've had a chance to fade to black.
    _player.change_state({'new_state': Player.State.SUSPENDED})
    _player.global_position = _suspend_point_post_warden.global_position
    yield(get_tree(), 'physics_frame')

    # Fade to black.
    var fade_duration := 2.0
    var fade_delay := 0.0
    var fade_music := true
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Disable room transitions for sector five lift. Make sure we also update
    # the camera limits accordingly.
    _sector_five_lift.set_enable_room_transitions(false)
    _player.get_camera().fit_camera_limits_to_room(_sector_five_lift)

    # Switch to cutscene camera.
    _sector_five_lift_cutscene_camera.make_current()

    # Switch to sector-specific visuals.
    _set_sector_five_visuals()

    # Switch to sector-specific music.
    MusicPlayer.stop(MusicPlayer.Music.WORLD_BASE)
    MusicPlayer.play(MusicPlayer.Music.WORLD_SECTOR_5)

    # Start the fall sequence from the second suspension point.
    _player.global_position = _sector_five_lift_suspend_point.global_position
    _player.set_direction(Util.Direction.RIGHT)
    yield(get_tree(), 'physics_frame')
    _player.change_state({'new_state': Player.State.SECTOR_FIVE_LIFT_FALL})

    # Fade from black.
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)

    if _player.current_state_enum == Player.State.SECTOR_FIVE_LIFT_FALL:
        yield(_player.current_state, 'sequence_finished')

    # Switch back to player camera.
    _player.get_camera().make_current()

    # Re-enable room transitions for sector five lift.
    _sector_five_lift.set_enable_room_transitions(true)

    # Reset previous/current room so that next room transition works properly.
    _player.prev_room = _sector_five_lift
    _player.curr_room = _sector_five_lift

func _on_arena_elevator_switch_pressed() -> void:
    # Pause player processing and switch to IDLE state. Note that we do not
    # pause physics processing because the player will be on a KinematicBody2D
    # elevator that has sync_to_physics enabled, so we need to ensure that
    # physics is still being processed on the player to avoid the elevator
    # moving right through the player.
    _player.set_process_unhandled_input(false)
    _player.change_state({'new_state': Player.State.IDLE})

    # Fade to black
    var fade_duration := 2.0
    var fade_delay := 1.0
    var fade_music := false
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Move player to elevator arena room.
    _player.global_position = _elevator_arena_room_elevator.global_position

    # Wait a bit to give the player camera time to catch up, thus avoiding weird
    # visual artifacts during the fade back from black.
    yield(get_tree().create_timer(0.5), 'timeout')

    # Start scrolling the elevator arena background to give the illusion of
    # motion.
    _elevator_arena_room.start_background_scrolling()

    # Switch to elevator music.
    MusicPlayer.cross_fade(
        MusicPlayer.Music.ESCAPE_SEQUENCE_3,
        MusicPlayer.Music.ESCAPE_SEQUENCE_ELEVATOR,
        1.0)

    # Fade back from black.
    fade_delay = 0.0
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_from_black_finished')

    # Resume player processing.
    _player.set_process_unhandled_input(true)

    # Start arena after waiting a bit.
    yield(get_tree().create_timer(1.0), 'timeout')
    _elevator_arena_room.start_arena()

func _on_elevator_arena_finished() -> void:
    # Start moving the arena's elevator upwards.
    _elevator_arena_room_elevator.move_to_destination()

    # Fade to black
    var fade_duration := 2.0
    var fade_delay := 1.0
    var fade_music := false
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Disable the escape sequence debris effects, since we don't want debris to
    # accidentally fall from the actual sky when we exit to the surface. The
    # alarm siren will continue to play as normal.
    EscapeSequenceEffects.stop_debris()

    # Pause player processing and switch to IDLE state. Note that we do not
    # pause physics processing because the player will be on a KinematicBody2D
    # elevator that has sync_to_physics enabled, so we need to ensure that
    # physics is still being processed on the player to avoid the elevator
    # moving right through the player.
    _player.set_process_unhandled_input(false)
    _player.change_state({'new_state': Player.State.IDLE})
    yield(get_tree(), 'physics_frame')

    # Disable room transitions on the destination room to avoid wonkiness with
    # the camera.
    _arena_elevator_end_room.set_enable_room_transitions(false)
    _player.get_camera().fit_camera_limits_to_room(_arena_elevator_end_room)

    # Move player to final elevator arena room (i.e. elevator's "destination").
    _player.global_position = _arena_elevator_end.global_position

    # Wait a bit to give the player camera time to catch up, thus avoiding weird
    # visual artifacts during the fade back from black.
    yield(get_tree().create_timer(0.5), 'timeout')

    # Start moving the final elevator upwards.
    _arena_elevator_end.move_to_destination()

    # Fade back from black.
    fade_delay = 1.0
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_from_black_finished')

    # Switch to elevator end music.
    MusicPlayer.cross_fade(
        MusicPlayer.Music.ESCAPE_SEQUENCE_ELEVATOR,
        MusicPlayer.Music.ESCAPE_SEQUENCE_ELEVATOR_END,
        0.5)

    # Resume player processing.
    _player.set_process_unhandled_input(true)

func _on_player_reached_surface(old_room: RoomFe, new_room: RoomFe) -> void:
    if new_room != _surface_exit:
        return

    # Play ambient sounds.
    _surface_exit.play_ambient_sounds()

    # Switch to grassy walk sound.
    _player.set_walk_sound(PlayerSoundManager.Sounds.WALK_GRASS)

    # Switch to surface visuals (e.g. character spritesheet) and fade out UI.
    _player.switch_to_surface_visuals()
    _health_bar.fade_out()
    _health_pack_bar.fade_out()

    # Stop escape sequence effects and the low-health vignette/heartbeat.
    EscapeSequenceEffects.stop()
    _vignette.stop()

    # Switch to surface cutscene state, which will ground the player, have them
    # walk to some predetermined points, and then face the moon.
    _player.change_state({
        'new_state': Player.State.SURFACE_CUTSCENE,
        'pause_point': _surface_exit.get_pause_point(),
        'stopping_point': _surface_exit.get_stopping_point(),
    })

    # Wait a bit and then close the door behind the player.
    yield(get_tree().create_timer(0.5), 'timeout')
    _surface_exit.get_closing_door().close()

    # Start credits music.
    yield(_player, 'player_reached_walk_to_point')
    MusicPlayer.play(MusicPlayer.Music.CREDITS)

    # Wait until the player has turned to look at the moon before eventually
    # fading to credits.
    yield(_player, 'player_looked_at_moon')
    yield(get_tree().create_timer(4.0), 'timeout')
    var fade_duration := 2.0
    var fade_music := false
    SceneChanger.change_scene_to(Preloads.CreditsScreen, fade_duration, fade_music)
