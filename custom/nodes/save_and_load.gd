extends Node

signal game_saved
signal game_loaded

const GROUP := 'save'
const SAVE_DIRECTORY := 'res://debug_save_data/'

enum SaveSlot {
    UNSET,
    SLOT_1,
    SLOT_2,
    SLOT_3,
}

# Save slot to use. This will be set by the title screen when a save slot is
# selected, and used throughout afterwards.
var save_slot: int = SaveSlot.UNSET

func save_game() -> void:
    assert(save_slot != SaveSlot.UNSET)

    var save_data := {}

    for node in get_tree().get_nodes_in_group(GROUP):
        var node_save_data: Array = node.get_save_data()

        # First element is the key, second is the value.
        assert(node_save_data.size() == 2)
        save_data[node_save_data[0]] = node_save_data[1]

    var dir := Directory.new()
    if not dir.dir_exists(SAVE_DIRECTORY):
        dir.make_dir_recursive(SAVE_DIRECTORY)

    var file := File.new()
    file.open(_get_save_file_path(), File.WRITE)
    file.store_string(to_json(save_data))
    file.close()

    emit_signal('game_saved')

func load_game() -> void:
    assert(save_slot != SaveSlot.UNSET)

    var all_save_data := _load_all_data()

    for node in get_tree().get_nodes_in_group(GROUP):
        node.load_save_data(all_save_data)

    emit_signal('game_loaded')

func _get_save_file_path() -> String:
    assert(save_slot != SaveSlot.UNSET)

    match save_slot:
        SaveSlot.SLOT_1:
            return SAVE_DIRECTORY + '1.json'
        SaveSlot.SLOT_2:
            return SAVE_DIRECTORY + '2.json'
        SaveSlot.SLOT_3:
            return SAVE_DIRECTORY + '3.json'
        _:
            return SAVE_DIRECTORY + 'error.json'

func _load_all_data() -> Dictionary:
    var file := File.new()

    var path := _get_save_file_path()

    # If the save file doesn't exist, assume that it's because the game is
    # being played for the very first time.
    if not file.file_exists(path):
        return {}

    file.open(path, File.READ)
    var save_data: Dictionary = parse_json(file.get_as_text())
    file.close()

    return save_data
