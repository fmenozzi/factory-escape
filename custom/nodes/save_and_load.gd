extends Node

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

func save_game() -> ErrorPlusMessage:
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
        if node_save_data.size() != 2:
            return ErrorPlusMessage.new(
                ERR_INVALID_DATA,
                'Expected 2 fields in node_save_data, got %d' % node_save_data.size())

        save_data[node_save_data[0]] = node_save_data[1]

    var dir := Directory.new()
    if not dir.dir_exists(_save_directory):
        var error := dir.make_dir_recursive(_save_directory)
        if error != OK:
            return ErrorPlusMessage.new(
                error, 'Could not create save directory %s' % _save_directory)

    var error_or_path := _get_save_file_path(save_slot)
    if error_or_path.error_plus_msg.error != OK:
        return error_or_path.error_plus_msg

    var path: String = error_or_path.value

    # Save data as formatted JSON using a two-space indent with sorted keys.
    var file := File.new()
    var error := file.open(path, File.WRITE)
    if error != OK:
        return ErrorPlusMessage.new(
            error, 'Could not open save file for slot %d' % save_slot)
    file.store_string(JSON.print(save_data, '  ', true))
    file.close()

    return ErrorPlusMessage.new()

func load_game() -> ErrorPlusMessage:
    return load_specific_nodes(get_tree().get_nodes_in_group(GROUP))

func load_specific_nodes(nodes_to_load: Array) -> ErrorPlusMessage:
    assert(save_slot != SaveSlot.UNSET)

    var error_or_all_save_data := _load_all_data(save_slot)
    if error_or_all_save_data.error_plus_msg.error != OK:
        return error_or_all_save_data.error_plus_msg

    var all_save_data: Dictionary = error_or_all_save_data.value

    # In case we run in standalone mode (i.e. we don't go through the title
    # screen to check for valid save versions), check here that any non-empty
    # save data has a valid version (_load_all_data() will return an empty dict
    # if the file doesn't exist, as would happen the first time the player plays
    # the game).
    if not all_save_data.empty():
        if not has_valid_version(save_slot):
            return ErrorPlusMessage.new(
                ERR_INVALID_DATA, 'Invalid version for slot %d' % save_slot)

    for node in nodes_to_load:
        match Version.full():
            '0.1.0':
                node.load_version_0_1_0(all_save_data)
            _:
                return ErrorPlusMessage.new(
                    ERR_INVALID_DATA, 'Invalid game version: ' + Version.full())

    return ErrorPlusMessage.new()

func has_save_data(save_slot_to_check: int) -> bool:
    # For now we just treat errors from _get_save_file_path() as indicative of
    # not having save data.
    var error_or_path := _get_save_file_path(save_slot_to_check)
    if error_or_path.error_plus_msg.error != OK:
        return false

    return File.new().file_exists(error_or_path.value)

func has_valid_version(save_slot_to_check: int) -> bool:
    # For now, we treat a loading error as indicative of not having a valid
    # version.
    var error_or_all_save_data := _load_all_data(save_slot_to_check)
    if error_or_all_save_data.error_plus_msg.error != OK:
        return false

    var all_save_data: Dictionary = error_or_all_save_data.value

    # Save data must have 'version' section.
    if not 'version' in all_save_data:
        return false

    # 'version' section must have 'major', 'minor', and 'patch' sections.
    var version: Dictionary = all_save_data['version']
    if not ('major' in version and 'minor' in version and 'patch' in version):
        return false

    # Save file version must match one of the supported versions.
    var full_version_from_save := '%d.%d.%d' % [
        version['major'],
        version['minor'],
        version['patch'],
    ]
    return full_version_from_save in Version.valid_versions()

func delete_save_data(save_slot_to_delete: int) -> ErrorPlusMessage:
    var error_or_path := _get_save_file_path(save_slot_to_delete)
    if error_or_path.error_plus_msg.error != OK:
        return error_or_path.error_plus_msg

    var path: String = error_or_path.value

    var dir := Directory.new()
    if not dir.file_exists(path):
        return ErrorPlusMessage.new()

    var error := dir.remove(path)
    if error != OK:
        return ErrorPlusMessage.new(error, 'Could not delete save slot %d' % save_slot)

    return ErrorPlusMessage.new()

func get_all_save_data() -> ErrorOr:
    return _load_all_data(save_slot)

func _get_save_file_path(save_slot_to_use: int) -> ErrorOr:
    match save_slot_to_use:
        SaveSlot.SLOT_1:
            return ErrorOr.new(_save_directory + '1.json')
        SaveSlot.SLOT_2:
            return ErrorOr.new(_save_directory + '2.json')
        SaveSlot.SLOT_3:
            return ErrorOr.new(_save_directory + '3.json')
        _:
            return ErrorOr.new(
                null,
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST, 'Save slot not set in _get_save_file_path()'))

func _load_all_data(save_slot_to_use: int) -> ErrorOr:
    var file := File.new()

    var error_or_path := _get_save_file_path(save_slot_to_use)
    if error_or_path.error_plus_msg.error != OK:
        return error_or_path

    var path: String = error_or_path.value

    # If the save file doesn't exist, assume that it's because the game is
    # being played for the very first time.
    if not file.file_exists(path):
        return ErrorOr.new({})

    var error := file.open(path, File.READ)
    if error != OK:
        return ErrorOr.new(
            null,
            ErrorPlusMessage.new(
                error,
                'Could not open save file for slot %d located at %s' % [save_slot, path]))

    var json := JSON.parse(file.get_as_text())
    if json.error != OK:
        return ErrorOr.new(
            null,
            ErrorPlusMessage.new(
                json.error, 'Could not parse JSON for slot %d' % save_slot))
    if typeof(json.result) != TYPE_DICTIONARY:
        return ErrorOr.new(
            null,
            ErrorPlusMessage.new(
                json.error,
                'Invalid JSON type for save slot %d: %d' % [save_slot, typeof(json.result)]))

    file.close()

    return ErrorOr.new(json.result)
