extends Control

onready var _label: Label = $Label

func _ready() -> void:
    var major: int = ProjectSettings.get_setting('application/version/major')
    var minor: int = ProjectSettings.get_setting('application/version/minor')
    var patch: int = ProjectSettings.get_setting('application/version/patch')

    assert(major >= 0 and minor >= 0 and patch >= 0, "Invalid game version.")

    _label.text = '%d.%d.%d' % [major, minor, patch]
