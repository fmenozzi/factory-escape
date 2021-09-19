extends "res://game/game_interface.gd"

onready var _cargo_lift: Room = $World/Rooms/CargoLift
onready var _central_hub: Room = $World/Rooms/CentralHub
onready var _dash_tutorial_trigger: Area2D = $World/Rooms/SectorOne_17/TutorialMessageTrigger
onready var _wall_jump_tutorial_trigger: Area2D = $World/Rooms/SectorTwo_13/TutorialMessageTrigger
onready var _double_jump_tutorial_trigger: Area2D = $World/Rooms/SectorThree_11/TutorialMessageTrigger
onready var _grapple_tutorial_trigger: Area2D = $World/Rooms/SectorFour_13/TutorialMessageTrigger
onready var _central_hub_suspend_point: Position2D = $World/Rooms/CentralHub/PlayerSuspensionPoint
onready var _central_hub_fall_sequence_camera_anchor: Position2D = $World/Rooms/CentralHub/FallSequenceCameraAnchor
onready var _central_lock_cutscene_camera: Camera2D = $World/Rooms/CentralHub/CentralLockCutsceneCamera
onready var _central_lock: CentralLock = $World/Rooms/CentralHub/CentralLock

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

    # Pin the camera to the central hub anchor.
    _player.get_camera().detach_and_move_to_global(
        _central_hub_fall_sequence_camera_anchor.global_position)

    # Start the fall sequence.
    _player.change_state({'new_state': Player.State.CENTRAL_HUB_FALL})

    # Fade from black.
    _screen_fadeout.fade_from_black(fade_duration, fade_delay, fade_music)

    if _player.current_state_enum == Player.State.CENTRAL_HUB_FALL:
        yield(_player.current_state, 'sequence_finished')

    # Reattach camera.
    var tween_duration := 0.0
    _player.get_camera().reattach(tween_duration)

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
    _screen_fadeout.fade_to_black(2.0)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Switch to cutscene camera.
    _central_lock_cutscene_camera.make_current()

    # Fade back from black.
    _screen_fadeout.fade_from_black(2.0)
    yield(_screen_fadeout, 'fade_from_black_finished')

    # Turn on corresponding light. If other lights are already playing their
    # pulse animation, wait until the right moment in their animation to begin
    # the animation sequence for turning on this light. This helps to ensure
    # that the pulses of all four lights are synchronized.
    if _central_lock.lights_already_pulsing():
        yield(_central_lock, 'ready_to_turn_on_new_light')
    match sector_number:
        1:
            _central_lock.turn_on_light(CentralLock.LockLight.UPPER_LEFT)
        2:
            _central_lock.turn_on_light(CentralLock.LockLight.UPPER_RIGHT)
        3:
            _central_lock.turn_on_light(CentralLock.LockLight.LOWER_LEFT)
        4:
            _central_lock.turn_on_light(CentralLock.LockLight.LOWER_RIGHT)

    # Wait a few seconds.
    yield(get_tree().create_timer(4.0), 'timeout')

    # Fade back to black.
    _screen_fadeout.fade_to_black(2.0)
    yield(_screen_fadeout, 'fade_to_black_finished')

    # Switch back to player camera.
    _player.get_camera().make_current()

    # Fade back from black.
    _screen_fadeout.fade_from_black(2.0)
    yield(_screen_fadeout, 'fade_from_black_finished')

    # Resume player processing.
    _player.set_process_unhandled_input(true)
    _player.set_physics_process(true)
