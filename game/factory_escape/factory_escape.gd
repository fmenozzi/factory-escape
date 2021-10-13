extends "res://game/game_interface.gd"

onready var _cargo_lift: Room = $World/Rooms/CargoLift
onready var _central_hub: Room = $World/Rooms/CentralHub
onready var _central_hub_save_manager: CentralHubSaveManager = $World/Rooms/CentralHub/SaveManager
onready var _central_hub_camera_focus_point: CameraFocusPoint = $World/Rooms/CentralHub/CameraFocusPoint
onready var _warden_spawn_point: Position2D = $World/Rooms/CentralHub/BossFight/WardenSpawnPoint
onready var _lightning_floor: LightningFloor = $World/Rooms/CentralHub/BossFight/LightningFloor
onready var _projectile_spawners: Array = $World/Rooms/CentralHub/BossFight/ProjectileSpawners.get_children()
onready var _dash_tutorial_trigger: Area2D = $World/Rooms/SectorOne_17/TutorialMessageTrigger
onready var _wall_jump_tutorial_trigger: Area2D = $World/Rooms/SectorTwo_13/TutorialMessageTrigger
onready var _double_jump_tutorial_trigger: Area2D = $World/Rooms/SectorThree_11/TutorialMessageTrigger
onready var _grapple_tutorial_trigger: Area2D = $World/Rooms/SectorFour_13/TutorialMessageTrigger
onready var _central_hub_suspend_point: Position2D = $World/Rooms/CentralHub/PlayerSuspensionPoint
onready var _central_lock_cutscene_camera: Camera2D = $World/Rooms/CentralHub/CentralLockCutsceneCamera
onready var _central_lock: CentralLock = $World/Rooms/CentralHub/CentralLock
onready var _central_lock_save_manager: CentralLockSaveManager = $World/Rooms/CentralHub/CentralLock/SaveManager

func _ready() -> void:
    _cargo_lift.connect('player_entered_cargo_lift', self, '_on_player_entered_cargo_lift')

    for ability in get_tree().get_nodes_in_group('abilities'):
        ability.connect('ability_acquired', self, '_on_ability_acquired')

        match ability.ability:
            Ability.Kind.DASH:
                ability.connect(
                    'ability_acquired', _player.get_dash_manager(), '_on_dash_acquired')

            Ability.Kind.DOUBLE_JUMP:
                ability.connect(
                    'ability_acquired', _player.get_jump_manager(), '_on_double_jump_acquired')

            Ability.Kind.WALL_JUMP:
                ability.connect(
                    'ability_acquired', _player.get_wall_jump_manager(), '_on_wall_jump_acquired')

            Ability.Kind.GRAPPLE:
                ability.connect(
                    'ability_acquired', _player.get_grapple_manager(), '_on_grapple_acquired')

    for central_lock_switch in get_tree().get_nodes_in_group('central_lock_switches'):
        central_lock_switch.connect('unlocked', self, '_on_central_lock_switch_pressed')

    _central_hub.connect('boss_fight_triggered', self, '_on_boss_fight_triggered')

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

func _on_ability_acquired(ability: int) -> void:
    _player.save_manager.last_saved_global_position = _player.global_position
    _player.save_manager.last_saved_direction_to_lamp = _player.get_direction()
    _maybe_save_game()

    match ability:
        Ability.Kind.DASH:
            _dash_tutorial_trigger.set_is_active(true)

        Ability.Kind.WALL_JUMP:
            _wall_jump_tutorial_trigger.set_is_active(true)

        Ability.Kind.DOUBLE_JUMP:
            _double_jump_tutorial_trigger.set_is_active(true)

        Ability.Kind.GRAPPLE:
            _grapple_tutorial_trigger.set_is_active(true)

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

    # Fade back from black.
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)
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

    # Fade back to black.
    _screen_fadeout.fade_to_black(fade_duration, fade_delay, fade_music)
    yield(_screen_fadeout, 'fade_to_black_finished')

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
    # Pause player processing and switch to IDLE state once the player is on the
    # ground but not near the door.
    _central_hub.set_process(true)

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

    # Spawn warden and wait for intro sequence to finish.
    var warden: Warden = Preloads.Warden.instance()
    _central_hub.add_child(warden)
    warden.global_position = _warden_spawn_point.global_position
    warden.set_direction(Util.direction(warden, _player))
    _connect_warden_signals(warden)
    yield(warden, 'intro_sequence_finished')

    # Resume player processing.
    _central_hub.set_process(false)
    _player.set_process_unhandled_input(true)
    _player.set_physics_process(true)

func _on_warden_died(warden: Warden) -> void:
    # Pause player processing and switch to IDLE state.
    _player.set_process_unhandled_input(false)
    _player.set_physics_process(false)
    _player.change_state({'new_state': Player.State.IDLE})

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
