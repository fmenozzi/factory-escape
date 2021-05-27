extends Node2D
class_name VisibilityBasedAudioPlayer

export(float, -80.0, 24.0) var max_volume_db := 0.0
export(AudioStream) var stream: AudioStream = null

onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
    assert(stream != null)

    _audio_stream_player.stream = stream
    _audio_stream_player.volume_db = max_volume_db

func set_volume_db(volume_db: float) -> void:
    _audio_stream_player.volume_db = volume_db

func get_player() -> AudioStreamPlayer:
    return _audio_stream_player
