extends "res://game.gd"

signal ability_chosen(ability_object)

onready var _confirmation_dialog: Control = $Layers/DialogBoxLayer/ConfirmationDialog

func _ready() -> void:
    ._ready()

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
        emit_signal('ability_chosen', ability)

    _player.set_process_unhandled_input(true)
