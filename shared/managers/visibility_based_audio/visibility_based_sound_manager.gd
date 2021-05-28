extends Node2D
class_name VisibilityBasedSoundManager

onready var _visibility_based_audio_groups: Array = $AudioGroups.get_children()

func _ready() -> void:
    assert(not _visibility_based_audio_groups.empty())
    for audio_group in _visibility_based_audio_groups:
        assert(audio_group is VisibilityBasedAudioGroup)

func get_all_audio_groups() -> Array:
    return _visibility_based_audio_groups

func set_all_muted(muted: bool) -> void:
    for audio_group in _visibility_based_audio_groups:
        audio_group.set_muted(muted)
