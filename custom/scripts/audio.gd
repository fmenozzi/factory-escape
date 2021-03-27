extends Node

func set_bus_volume_linear(bus: String, volume_linear: float) -> void:
    assert(0.0 <= volume_linear and volume_linear <= 1.0)
    assert(bus in ['Music', 'Effects', 'UI'])

    # Convert linear value [0, 1] to decibel value [-80, 0].
    var volume_db := max(linear2db(volume_linear), -80)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume_db)
