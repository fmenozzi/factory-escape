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

        assert(options_data.size() == 2)

        var section: String = options_data[0]
        var data: Dictionary = options_data[1]

        for key in data:
            _config.set_value(section, key, data[key])

    var dir := Directory.new()
    if not dir.dir_exists(_save_directory):
        dir.make_dir_recursive(_save_directory)

    var status := _config.save(_get_file_path())
    assert(status == OK)

    emit_signal('options_saved')

func load_options() -> void:
    _load_config(_config)

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
                    assert(false, 'Invalid options version: ' + Version.full())

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

func _load_config(config_file: ConfigFile) -> void:
    var path := _get_file_path()

    var status := config_file.load(path)
    if status != OK:
        assert(status == ERR_FILE_NOT_FOUND)

        # Create new config file if it doesn't already exist.
        var file := File.new()
        file.open(path, File.WRITE)
        file.close()

        # Add current game version to config.
        assert(config_file.load(path) == OK)
        config_file.set_value('version', 'major', Version.major())
        config_file.set_value('version', 'minor', Version.minor())
        config_file.set_value('version', 'patch', Version.patch())
