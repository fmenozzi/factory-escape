extends "res://game/game_interface.gd"

onready var _cargo_lift: Room = $World/Rooms/CargoLift
onready var _central_hub: Room = $World/Rooms/CentralHub
onready var _dash_tutorial_trigger: Area2D = $World/Rooms/SectorOne_17/TutorialMessageTrigger
onready var _wall_jump_tutorial_trigger: Area2D = $World/Rooms/SectorTwo_13/TutorialMessageTrigger
onready var _double_jump_tutorial_trigger: Area2D = $World/Rooms/SectorThree_11/TutorialMessageTrigger
onready var _grapple_tutorial_trigger: Area2D = $World/Rooms/SectorFour_13/TutorialMessageTrigger
onready var _central_hub_suspend_point: Position2D = $World/Rooms/CentralHub/PlayerSuspensionPoint
onready var _central_hub_fall_sequence_camera_anchor: Position2D = $World/Rooms/CentralHub/FallSequenceCameraAnchor

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
    var tween_on_reattach := false
    _player.get_camera().reattach(tween_on_reattach)

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
