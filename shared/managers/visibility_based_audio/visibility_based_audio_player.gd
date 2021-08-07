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

func play() -> void:
    _audio_stream_player.play()

func stop() -> void:
    # Include the call to seek() to ensure that the sound stops playing when
    # stop() is called. This was not always previously the case, as there were
    # instances where looping audio would continue to play if stop() was called
    # too soon after play().
    _audio_stream_player.seek(-1)
    _audio_stream_player.stop()

func get_player() -> AudioStreamPlayer:
    return _audio_stream_player
