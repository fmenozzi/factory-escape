extends 'res://game/game_interface.gd'

signal ability_chosen(ability_object)

var _generated_rooms := false

const ABILITY_ROOMS := {
    DemoAbility.Ability.DASH: [
        [preload('res://game/demo/rooms/dash/DashTutorial.tscn'), Vector2(3840, 1080)],
        [preload('res://game/demo/rooms/dash/DashPractice.tscn'), Vector2(4160, 900)],
        [preload('res://game/demo/rooms/dash/SentryDroneCalibration.tscn'), Vector2(4480, 900)],
        [preload('res://game/demo/rooms/dash/CalibrationBridge.tscn'), Vector2(5120, 900)],
        [preload('res://game/demo/rooms/dash/SecurityCheckpoint.tscn'), Vector2(5440, 900)],
        [preload('res://game/demo/rooms/dash/CheckpointCorridor.tscn'), Vector2(5760, 1080)],
        [preload('res://game/demo/rooms/dash/CheckpointLamp.tscn'), Vector2(6400, 1080)],
        [preload('res://game/demo/rooms/dash/CentralProcessing.tscn'), Vector2(6720, 900)],
        [preload('res://game/demo/rooms/dash/SecondaryProcessing.tscn'), Vector2(7360, 1080)],
        [preload('res://game/demo/rooms/dash/ProcessingArena.tscn'), Vector2(7360, 1440)],
        [preload('res://game/demo/rooms/dash/DashEnd.tscn'), Vector2(8000, 1440)],
    ],

    DemoAbility.Ability.DOUBLE_JUMP: [
        [preload('res://game/demo/rooms/double_jump/DoubleJumpTutorial.tscn'), Vector2(3840, 1080)],
        [preload('res://game/demo/rooms/double_jump/DoubleJumpPracticeAntechamber.tscn'), Vector2(4160, 1080)],
        [preload('res://game/demo/rooms/double_jump/DoubleJumpPractice.tscn'), Vector2(4480, 900)],
        [preload('res://game/demo/rooms/double_jump/PrimaryContainment.tscn'), Vector2(4800, 900)],
        [preload('res://game/demo/rooms/double_jump/SecondaryContainment.tscn'), Vector2(5440, 900)],
        [preload('res://game/demo/rooms/double_jump/ContainmentJunction.tscn'), Vector2(5760, 1080)],
        [preload('res://game/demo/rooms/double_jump/ContainmentCorridor.tscn'), Vector2(6080, 1080)],
        [preload('res://game/demo/rooms/double_jump/ContainmentLamp.tscn'), Vector2(6720, 1080)],
        [preload('res://game/demo/rooms/double_jump/ContainmentControl.tscn'), Vector2(7040, 900)],
        [preload('res://game/demo/rooms/double_jump/ContainmentShaftConnector.tscn'), Vector2(7680, 1080)],
        [preload('res://game/demo/rooms/double_jump/ContainmentShaft.tscn'), Vector2(8000, 720)],
        [preload('res://game/demo/rooms/double_jump/ContainmentArena.tscn'), Vector2(8320, 720)],
        [preload('res://game/demo/rooms/double_jump/DoubleJumpEnd.tscn'), Vector2(8960, 720)],
    ],

    DemoAbility.Ability.GRAPPLE: [
        [preload('res://game/demo/rooms/grapple/GrappleTutorial.tscn'), Vector2(3840, 1080)],
        [preload('res://game/demo/rooms/grapple/GrapplePractice.tscn'), Vector2(4160, 900)],
        [preload('res://game/demo/rooms/grapple/SpikeTrap.tscn'), Vector2(4480, 900)],
        [preload('res://game/demo/rooms/grapple/MaintenanceTunnel.tscn'), Vector2(4800, 900)],
        [preload('res://game/demo/rooms/grapple/UShaft.tscn'), Vector2(5440, 900)],
        [preload('res://game/demo/rooms/grapple/UShaftConnector.tscn'), Vector2(5760, 900)],
        [preload('res://game/demo/rooms/grapple/GrappleLamp.tscn'), Vector2(6080, 900)],
        [preload('res://game/demo/rooms/grapple/NShaft.tscn'), Vector2(6400, 720)],
        [preload('res://game/demo/rooms/grapple/NShaftConnector.tscn'), Vector2(6720, 900)],
        [preload('res://game/demo/rooms/grapple/HazardTunnel.tscn'), Vector2(7360, 900)],
        [preload('res://game/demo/rooms/grapple/ArenaAntechamber.tscn'), Vector2(8000, 900)],
        [preload('res://game/demo/rooms/grapple/GrappleArena.tscn'), Vector2(8000, 1080)],
        [preload('res://game/demo/rooms/grapple/GrappleEnd.tscn'), Vector2(8320, 1080)],
    ],

    DemoAbility.Ability.WALL_JUMP: [
        [preload('res://game/demo/rooms/wall_jump/WallJumpTutorial.tscn'), Vector2(3840, 1080)],
        [preload('res://game/demo/rooms/wall_jump/WallJumpPracticeAntechamber.tscn'), Vector2(4160, 1080)],
        [preload('res://game/demo/rooms/wall_jump/WallJumpPractice.tscn'), Vector2(4480, 900)],
        [preload('res://game/demo/rooms/wall_jump/SiloAntechamber.tscn'), Vector2(4800, 1080)],
        [preload('res://game/demo/rooms/wall_jump/SecondarySiloStorage.tscn'), Vector2(5120, 1080)],
        [preload('res://game/demo/rooms/wall_jump/SiloObservation.tscn'), Vector2(5760, 1080)],
        [preload('res://game/demo/rooms/wall_jump/SiloLamp.tscn'), Vector2(6080, 1080)],
        [preload('res://game/demo/rooms/wall_jump/CargoLift.tscn'), Vector2(6400, 1080)],
        [preload('res://game/demo/rooms/wall_jump/CargoProcessing.tscn'), Vector2(6720, 1260)],
        [preload('res://game/demo/rooms/wall_jump/ProcessingConnector.tscn'), Vector2(7360, 1260)],
        [preload('res://game/demo/rooms/wall_jump/SiloConnector.tscn'), Vector2(7680, 1260)],
        [preload('res://game/demo/rooms/wall_jump/PrimarySiloStorage.tscn'), Vector2(8000, 720)],
        [preload('res://game/demo/rooms/wall_jump/SiloArena.tscn'), Vector2(8320, 720)],
        [preload('res://game/demo/rooms/wall_jump/WallJumpEnd.tscn'), Vector2(8960, 720)],
    ],
}

const EndOfDemoMessage := preload('res://game/demo/end_of_demo_message/EndOfDemoMessage.tscn')

onready var _confirmation_dialog: Control = $Layers/DialogBoxLayer/ConfirmationDialog
onready var _rooms_node: Node2D = $World/Rooms
onready var _ability_selection_room: Room = $World/Rooms/AbilitySelection
onready var _save_manager: DemoSaveManager = $SaveManager

func _ready() -> void:
    for demo_ability in get_tree().get_nodes_in_group('demo_ability'):
        demo_ability.connect('ability_inspected', self, '_on_ability_inspected')
        self.connect('ability_chosen', demo_ability, '_on_ability_chosen')

    self.connect(
        'ability_chosen', _player.get_jump_manager(), '_on_ability_chosen')
    self.connect(
        'ability_chosen', _player.get_dash_manager(), '_on_ability_chosen')
    self.connect(
        'ability_chosen', _player.get_grapple_manager(), '_on_ability_chosen')
    self.connect(
        'ability_chosen', _player.get_wall_jump_manager(), '_on_ability_chosen')

    self.connect(
        'ability_chosen', _ability_selection_room, '_on_ability_chosen')

func _generate_ability_specific_demo_rooms() -> void:
    # Need to get this node here because the existing onready var will be null
    # when this is called from the save manager's load function.
    var save_manager: DemoSaveManager = $SaveManager

    assert(save_manager.chosen_ability in [
        DemoAbility.Ability.DASH,
        DemoAbility.Ability.DOUBLE_JUMP,
        DemoAbility.Ability.GRAPPLE,
        DemoAbility.Ability.WALL_JUMP,
    ])

    # If we've already added the dynamic rooms to the scene tree, exit early.
    # This is mainly to prevent adding multiple copies of the same room to the
    # scene tree when the demo is reloaded upon player death.
    if _generated_rooms:
        return

    _generated_rooms = true

    var room_position_pairs: Array = ABILITY_ROOMS[save_manager.chosen_ability]

    var all_generated_rooms := []

    for room_position_pair in room_position_pairs:
        var room_packed_scene: PackedScene = room_position_pair[0]
        var position: Vector2 = room_position_pair[1]

        var room: Room = room_packed_scene.instance()
        room.position = position

        all_generated_rooms.append(room)

        # Add the room to the tree.
        #
        # TODO: why is this null when cached via onready?
        $World/Rooms.add_child(room)

    # Since SaveAndLoad.load_game() was called before these rooms (and any of
    # their nodes) were generated, ensure that each such node has a chance to
    # get loaded in.
    var generated_nodes_to_load := []
    for node in get_tree().get_nodes_in_group('save'):
        for generated_room in all_generated_rooms:
            # Check if the room itself needs to be loaded.
            if generated_room == node:
                generated_nodes_to_load.append(node)

            # Check if the node is a descendant of a generated room and thus
            # also in need of being loaded.
            if node.find_parent(generated_room.name):
                generated_nodes_to_load.append(node)

    # Load in the generated save-and-load nodes.
    #
    # Encountering an error here should be very rare, as errors should have
    # been caught at the title screen (in regular mode) or by the parent
    # _ready() function (in standalone mode). Nevertheless, it is possible
    # that e.g. the file somehow becomes corrupt during gameplay before the
    # player reaches the ability selection room (and thus generates the demo
    # rooms and loads them in). Such errors are caught here.
    SaveAndLoad.load_specific_nodes_and_report_errors(generated_nodes_to_load)

    # Connect all tutorial message trigger signals now that we're generating new
    # rooms with new triggers.
    $Layers/UILayer/TutorialMessage.connect_trigger_signals()

    # Connect end-of-demo message trigger signals.
    for trigger in get_tree().get_nodes_in_group('end_of_demo_message_trigger'):
        trigger.connect('end_of_demo_reached', self, '_on_end_of_demo_reached')

    # Re-connect lamp-related signals. This prevents bugs where demo lamps don't
    # work if the player skips the post-prelude-arena lamp.
    for lamp in get_tree().get_nodes_in_group('lamps'):
        lamp.connect('lamp_lit', self, '_on_player_lit_lamp')
        lamp.connect('rested_at_lamp', self, '_on_player_rested_at_lamp')

    # Re-connect health pack-related signals. This prevents bugs where demo
    # health packs don't work if the player skips the post-prelude-arena lamp.
    for health_pack in get_tree().get_nodes_in_group('health_packs'):
        health_pack.connect('health_pack_taken', self, '_on_health_pack_taken')

func _on_ability_inspected(demo_ability: DemoAbility) -> void:
    _player.set_process_unhandled_input(false)

    var ability := demo_ability.ability

    # Start READ_SIGN sequence (we're treating the ability object as a sign).
    _player.change_state({
        'new_state': Player.State.READ_SIGN,
        'stopping_point': demo_ability.get_closest_reading_point(),
        'object_to_face': demo_ability,
    })
    yield(_player.current_state, 'sequence_finished')

    var ability_string := ''
    match ability:
        DemoAbility.Ability.DASH:
            ability_string = 'DASH'
        DemoAbility.Ability.DOUBLE_JUMP:
            ability_string = 'DOUBLE JUMP'
        DemoAbility.Ability.GRAPPLE:
            ability_string = 'GRAPPLE'
        DemoAbility.Ability.WALL_JUMP:
            ability_string = 'WALL JUMP'

    _confirmation_dialog.show_dialog(
        'Choose %s ability? This selection is permanent.' % ability_string)

    # Wait for the player to accept or decline the given ability
    var ability_chosen: bool = yield(_confirmation_dialog, 'selection_made')

    if ability_chosen:
        _save_manager.chosen_ability = ability

        _generate_ability_specific_demo_rooms()

        emit_signal('ability_chosen', ability)

    _player.set_process_unhandled_input(true)

func _on_end_of_demo_reached() -> void:
    var player: Player = Util.get_player()
    assert(player != null)

    # Disable player control once they fall through the trigger.
    player.set_process_unhandled_input(false)

    # Prevent player from making any more sounds.
    player.get_sound_manager().pause_all()

    var fade_in_delay := 2.0
    SceneChanger.change_scene_to(EndOfDemoMessage, fade_in_delay)
