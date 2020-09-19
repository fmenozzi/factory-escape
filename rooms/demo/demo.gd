extends "res://game.gd"

signal ability_chosen(ability_object)

const SAVE_KEY := 'demo'
const UNCHOSEN_ABILITY := -1

var _chosen_ability := UNCHOSEN_ABILITY

var _generated_rooms := false

const ABILITY_ROOMS := {
    DemoAbility.Ability.DASH: [
        [preload('res://rooms/demo/rooms/dash/DashTutorial.tscn'), Vector2(3840, 1080)],
        [preload('res://rooms/demo/rooms/dash/DashPractice.tscn'), Vector2(4160, 900)],
        [preload('res://rooms/demo/rooms/dash/SentryDroneCalibration.tscn'), Vector2(4480, 900)],
        [preload('res://rooms/demo/rooms/dash/CalibrationBridge.tscn'), Vector2(5120, 900)],
        [preload('res://rooms/demo/rooms/dash/SecurityCheckpoint.tscn'), Vector2(5440, 900)],
        [preload('res://rooms/demo/rooms/dash/CheckpointCorridor.tscn'), Vector2(5760, 1080)],
        [preload('res://rooms/demo/rooms/dash/CheckpointLamp.tscn'), Vector2(6400, 1080)],
        [preload('res://rooms/demo/rooms/dash/CentralProcessing.tscn'), Vector2(6720, 900)],
        [preload('res://rooms/demo/rooms/dash/SecondaryProcessing.tscn'), Vector2(7360, 1080)],
        [preload('res://rooms/demo/rooms/dash/ProcessingArena.tscn'), Vector2(7360, 1440)],
        [preload('res://rooms/demo/rooms/dash/DashEnd.tscn'), Vector2(8000, 1440)],
    ],

    DemoAbility.Ability.DOUBLE_JUMP: [
        [preload('res://rooms/demo/rooms/double_jump/DoubleJumpTutorial.tscn'), Vector2(3840, 1080)],
        [preload('res://rooms/demo/rooms/double_jump/DoubleJumpPracticeAntechamber.tscn'), Vector2(4160, 1080)],
        [preload('res://rooms/demo/rooms/double_jump/DoubleJumpPractice.tscn'), Vector2(4480, 900)],
        [preload('res://rooms/demo/rooms/double_jump/PrimaryContainment.tscn'), Vector2(4800, 900)],
        [preload('res://rooms/demo/rooms/double_jump/SecondaryContainment.tscn'), Vector2(5440, 900)],
        [preload('res://rooms/demo/rooms/double_jump/ContainmentJunction.tscn'), Vector2(5760, 1080)],
        [preload('res://rooms/demo/rooms/double_jump/ContainmentCorridor.tscn'), Vector2(6080, 1080)],
        [preload('res://rooms/demo/rooms/double_jump/ContainmentLamp.tscn'), Vector2(6720, 1080)],
        [preload('res://rooms/demo/rooms/double_jump/ContainmentControl.tscn'), Vector2(7040, 900)],
    ],

    DemoAbility.Ability.GRAPPLE: [
        [preload('res://rooms/demo/rooms/grapple/GrappleTutorial.tscn'), Vector2(3840, 1080)],
    ],

    DemoAbility.Ability.WALL_JUMP: [
        [preload('res://rooms/demo/rooms/wall_jump/WallJumpTutorial.tscn'), Vector2(3840, 1080)],
    ],
}

onready var _confirmation_dialog: Control = $Layers/DialogBoxLayer/ConfirmationDialog
onready var _rooms_node: Node2D = $World/Rooms
onready var _ability_selection_room: Room = $World/Rooms/AbilitySelection

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

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'chosen_ability': _chosen_ability,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var demo_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('chosen_ability' in demo_save_data)

    _chosen_ability = demo_save_data['chosen_ability']

    if _chosen_ability != UNCHOSEN_ABILITY:
        # "Remove" demo abilities once one has been chosen in order to prevent
        # the player from choosing again if they quit out before reaching the
        # abilities lamp.
        for demo_ability in get_tree().get_nodes_in_group('demo_ability'):
            demo_ability.make_non_interactable()
            demo_ability.hide()

        # In case the player quit out before reaching the abilities lamp, open
        # the doors to the ability selection room and ensure they don't close
        # again when the player enters.
        #
        # TODO: why is this null when cached via onready? load_save_data() is
        #       called in the parent _ready() function, but it should still
        #       be non-null before then...
        $World/Rooms/AbilitySelection.open_doors_and_keep_them_open()

        _generate_ability_specific_demo_rooms()

func _generate_ability_specific_demo_rooms() -> void:
    assert(_chosen_ability in [
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

    var room_position_pairs: Array = ABILITY_ROOMS[_chosen_ability]

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
    var all_save_data := SaveAndLoad.get_all_save_data()
    for node in generated_nodes_to_load:
        node.load_save_data(all_save_data)

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
        _chosen_ability = ability

        _generate_ability_specific_demo_rooms()

        emit_signal('ability_chosen', ability)

    _player.set_process_unhandled_input(true)
