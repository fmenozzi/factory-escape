extends Node

signal options_saved
signal options_loaded

const GROUP := 'options'

var _config := ConfigFile.new()

onready var _save_directory: String = ProjectSettings.get_setting('application/save_directory')

func _ready() -> void:
    assert(_save_directory.ends_with('/'))

func save_options() -> void:
    # Add section for game version.
    _config.set_value('version', 'major', Version.major())
    _config.set_value('version', 'minor', Version.minor())
    _config.set_value('version', 'patch', Version.patch())

    # Add remaining sections.
    for node in get_tree().get_nodes_in_group(GROUP):
        var options_data: Array = node.get_options_data()

        if options_data.size() != 2:
            _handle_error('Expected 2 fields in options_data, got %d' % options_data.size())

        var section: String = options_data[0]
        var data: Dictionary = options_data[1]

        for key in data:
            _config.set_value(section, key, data[key])

    var dir := Directory.new()
    if not dir.dir_exists(_save_directory):
        var error := dir.make_dir_recursive(_save_directory)
        if error != OK:
            _handle_error('Could not create save directory %s' % _save_directory)

    var error := _config.save(_get_file_path())
    if error != OK:
        _handle_error('Could not save options, error code %d' % error)

    emit_signal('options_saved')

func load_options() -> void:
    var error := _load_config(_config)
    if error != OK:
        _handle_error('Could not load config, error code %d' % error)

    # If we don't have a valid config version, simply reset to the defaults for
    # the current game version. Otherwise, call the appropriate load function
    # for the current game version.
    if not has_valid_version(_config):
        for node in get_tree().get_nodes_in_group(GROUP):
            node.reset_to_defaults()
    else:
        for node in get_tree().get_nodes_in_group(GROUP):
            match Version.full():
                '0.1.0':
                    node.load_options_version_0_1_0(_config)
                _:
                    _handle_error('Invalid options version: ' + Version.full())

    emit_signal('options_loaded')

func has_valid_version(config_file: ConfigFile) -> bool:
    # Config file must have 'version' section.
    if not config_file.has_section('version'):
        return false

    # 'version' section must have 'major', 'minor', and 'patch' keys.
    if not config_file.has_section_key('version', 'major') or \
       not config_file.has_section_key('version', 'minor') or \
       not config_file.has_section_key('version', 'patch'):
        return false

    # Config file version must match one of the supported versions.
    var full_version_from_config := '%d.%d.%d' % [
        config_file.get_value('version', 'major'),
        config_file.get_value('version', 'minor'),
        config_file.get_value('version', 'patch'),
    ]
    return full_version_from_config in Version.valid_versions()

func get_config() -> ConfigFile:
    return _config

func _get_file_path() -> String:
    return _save_directory + 'options.cfg'

func _load_config(config_file: ConfigFile) -> int:
    var path := _get_file_path()

    var error := config_file.load(path)
    if error == OK:
        return OK

    # It's ok if the file doesn't exist (which would be the case the first
    # time the player plays the game), but any other error here is not ok.
    if error != ERR_FILE_NOT_FOUND:
        return error

    # Create new config file if it doesn't already exist.
    var file := File.new()
    error = file.open(path, File.WRITE)
    if error != OK:
        return error
    file.close()

    # Add current game version to config.
    error = config_file.load(path)
    if error != OK:
        return error
    config_file.set_value('version', 'major', Version.major())
    config_file.set_value('version', 'minor', Version.minor())
    config_file.set_value('version', 'patch', Version.patch())

    return OK

func _handle_error(error_msg: String) -> void:
    assert(false, error_msg)
