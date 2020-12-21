extends Node
class_name Version

static func major() -> int:
    return ProjectSettings.get_setting('application/version/major')

static func minor() -> int:
    return ProjectSettings.get_setting('application/version/minor')

static func patch() -> int:
    return ProjectSettings.get_setting('application/version/patch')

static func full() -> String:
    var major := major()
    var minor := minor()
    var patch := patch()

    assert(major >= 0 and minor >= 0 and patch >= 0, 'Invalid game version.')

    return '%d.%d.%d' % [major, minor, patch]

static func valid_versions() -> Array:
    return ProjectSettings.get_setting('application/version/valid_versions')
