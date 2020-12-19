extends Node
class_name DemoSaveManager

const SAVE_KEY := 'demo'
const UNCHOSEN_ABILITY := -1

var chosen_ability := UNCHOSEN_ABILITY

onready var _demo = get_parent()

func get_save_data() -> Array:
    return [SAVE_KEY, {
        'chosen_ability': chosen_ability,
    }]

func load_save_data(all_save_data: Dictionary) -> void:
    if not SAVE_KEY in all_save_data:
        return

    var demo_save_data: Dictionary = all_save_data[SAVE_KEY]
    assert('chosen_ability' in demo_save_data)

    chosen_ability = demo_save_data['chosen_ability']

    if chosen_ability != UNCHOSEN_ABILITY:
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
        _demo.get_node('World/Rooms/AbilitySelection').open_doors_and_keep_them_open()

        _demo._generate_ability_specific_demo_rooms()
