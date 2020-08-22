extends Node

signal options_saved
signal options_loaded

const GROUP := 'options'
const SAVE_DIRECTORY := 'user://save_data/'

var _config := ConfigFile.new()

func save_options() -> void:
    for node in get_tree().get_nodes_in_group(GROUP):
        var options_data: Array = node.get_options_data()

        assert(options_data.size() == 2)

        var section: String = options_data[0]
        var data: Dictionary = options_data[1]

        for key in data:
            _config.set_value(section, key, data[key])

    var dir := Directory.new()
    if not dir.dir_exists(SAVE_DIRECTORY):
        dir.make_dir_recursive(SAVE_DIRECTORY)

    var status := _config.save(_get_file_path())
    assert(status == OK)

    emit_signal('options_saved')

func load_options() -> void:
    var status := _config.load(_get_file_path())
    if status != OK:
        assert(status == ERR_FILE_NOT_FOUND)
        var file := File.new()
        file.open(_get_file_path(), File.WRITE)
        file.close()

    for node in get_tree().get_nodes_in_group(GROUP):
        node.load_options_data(_config)

    emit_signal('options_loaded')

func get_config() -> ConfigFile:
    return _config

func _get_file_path() -> String:
    return SAVE_DIRECTORY + 'options.cfg'
