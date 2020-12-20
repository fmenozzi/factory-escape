extends Node

signal game_saved
signal game_loaded

const GROUP := 'save'

enum SaveSlot {
    UNSET,
    SLOT_1,
    SLOT_2,
    SLOT_3,
}

# Save slot to use. This will be set by the title screen when a save slot is
# selected, and used throughout afterwards.
var save_slot: int = SaveSlot.UNSET

onready var _save_directory: String = ProjectSettings.get_setting('application/save_directory')

func _ready() -> void:
    assert(_save_directory.ends_with('/'))

func save_game() -> void:
    assert(save_slot != SaveSlot.UNSET)

    var save_data := {}

    # Add section for game version.
    save_data['version'] = {
        'major': Version.major(),
        'minor': Version.minor(),
        'patch': Version.patch(),
    }

    # Add remaining sections.
    for node in get_tree().get_nodes_in_group(GROUP):
        var node_save_data: Array = node.get_save_data()

        # First element is the key, second is the value.
        assert(node_save_data.size() == 2)
        save_data[node_save_data[0]] = node_save_data[1]

    var dir := Directory.new()
    if not dir.dir_exists(_save_directory):
        dir.make_dir_recursive(_save_directory)

    # Save data as formatted JSON using a two-space indent with sorted keys.
    var file := File.new()
    file.open(_get_save_file_path(save_slot), File.WRITE)
    file.store_string(JSON.print(save_data, '  ', true))
    file.close()

    emit_signal('game_saved')

func load_game() -> void:
    load_specific_nodes(get_tree().get_nodes_in_group(GROUP))

func load_specific_nodes(nodes_to_load: Array) -> void:
    assert(save_slot != SaveSlot.UNSET)

    var all_save_data := _load_all_data(save_slot)

    for node in nodes_to_load:
        match Version.full():
            '0.1.0':
                node.load_version_0_1_0(all_save_data)
            _:
                assert(false, 'Invalid save version: ' + Version.full())

    emit_signal('game_loaded')

func has_save_data(save_slot_to_check: int) -> bool:
    return File.new().file_exists(_get_save_file_path(save_slot_to_check))

func has_valid_version(save_slot_to_check: int) -> bool:
    # Save data must have 'version' section.
    var all_save_data := _load_all_data(save_slot_to_check)
    if not 'version' in all_save_data:
        return false

    # 'version' section must have 'major', 'minor', and 'patch' sections.
    var version: Dictionary = all_save_data['version']
    if not ('major' in version and 'minor' in version and 'patch' in version):
        return false

    var major_from_save: int = version['major']
    var minor_from_save: int = version['minor']
    var patch_from_save: int = version['patch']

    # Major versions must match.
    if major_from_save != Version.major():
        return false

    # Save minor version cannot be newer than game minor version
    if minor_from_save > Version.minor():
        return false

    # Save patch version cannot be newer than game patch version
    if patch_from_save > Version.patch():
        return false

    return true

func delete_save_data(save_slot_to_delete: int) -> void:
    var dir := Directory.new()

    var path := _get_save_file_path(save_slot_to_delete)
    if not dir.file_exists(path):
        return

    var status := dir.remove(path)
    assert(status == OK)

func get_all_save_data() -> Dictionary:
    return _load_all_data(save_slot)

func _get_save_file_path(save_slot_to_use: int) -> String:
    assert(save_slot_to_use != SaveSlot.UNSET)

    match save_slot_to_use:
        SaveSlot.SLOT_1:
            return _save_directory + '1.json'
        SaveSlot.SLOT_2:
            return _save_directory + '2.json'
        SaveSlot.SLOT_3:
            return _save_directory + '3.json'
        _:
            return _save_directory + 'error.json'

func _load_all_data(save_slot_to_use: int) -> Dictionary:
    var file := File.new()

    var path := _get_save_file_path(save_slot_to_use)

    # If the save file doesn't exist, assume that it's because the game is
    # being played for the very first time.
    if not file.file_exists(path):
        return {}

    file.open(path, File.READ)
    var json_parse_result := JSON.parse(file.get_as_text())
    assert(json_parse_result.error == OK)
    assert(typeof(json_parse_result.result) == TYPE_DICTIONARY)
    file.close()

    return json_parse_result.result
