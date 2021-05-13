extends Node

var _bus_to_max_volume_linear := {}

func _ready() -> void:
    _bus_to_max_volume_linear['Music'] = 1.0
    _bus_to_max_volume_linear['Effects'] = 1.0
    _bus_to_max_volume_linear['UI'] = 1.0

func linear_to_db(volume_linear: float, max_volume_db: float = 0.0) -> float:
    assert(0.0 <= volume_linear and volume_linear <= 1.0)

    # Convert linear value [0, 1] to decibel value [-80, max_volume_db].
    return clamp(linear2db(volume_linear), -80.0, max_volume_db)

func set_bus_volume_linear(bus: String, volume_linear: float) -> void:
    assert(0.0 <= volume_linear and volume_linear <= 1.0)
    assert(bus in ['Music', 'Effects', 'UI'])

    # Make sure new volume does not exceed the max linear volume for this bus.
    var volume_linear_clamped := min(_bus_to_max_volume_linear[bus], volume_linear)

    # Convert linear value [0, 1] to decibel value [-80, 0].
    var volume_db := linear_to_db(volume_linear_clamped)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume_db)

func get_bus_volume_linear(bus: String) -> float:
    assert(bus in ['Music', 'Effects', 'UI'])

    return db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus)))

func set_bus_max_volume_linear(bus: String, max_volume_linear: float) -> void:
    assert(bus in ['Music', 'Effects', 'UI'])
    assert(bus in _bus_to_max_volume_linear)

    _bus_to_max_volume_linear[bus] = max_volume_linear

    set_bus_volume_linear(bus, max_volume_linear)

func get_bus_max_volume_linear(bus: String) -> float:
    assert(bus in ['Music', 'Effects', 'UI'])
    assert(bus in _bus_to_max_volume_linear)

    return _bus_to_max_volume_linear[bus]

func reset_bus_to_max_volume_linear(bus: String) -> void:
    assert(bus in ['Music', 'Effects', 'UI'])
    assert(bus in _bus_to_max_volume_linear)

    set_bus_volume_linear(bus, _bus_to_max_volume_linear[bus])
