extends Node2D
class_name ConveyorBeltAudioGroup

onready var _audio_group: VisibilityBasedAudioGroup = $VisibilityBasedAudioGroup

func pause() -> void:
    _audio_group.get_player_by_name('Base').stop()
    _audio_group.get_player_by_name('Cadence').stop()

func resume() -> void:
    _audio_group.get_player_by_name('Base').play()
    _audio_group.get_player_by_name('Cadence').play()
