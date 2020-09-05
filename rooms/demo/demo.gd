extends "res://game.gd"

signal ability_chosen(ability_object)

const SAVE_KEY := 'demo'
const UNCHOSEN_ABILITY := -1

var _chosen_ability := UNCHOSEN_ABILITY

onready var _confirmation_dialog: Control = $Layers/DialogBoxLayer/ConfirmationDialog
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

        emit_signal('ability_chosen', ability)

    _player.set_process_unhandled_input(true)
