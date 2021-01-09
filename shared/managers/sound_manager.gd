tool
extends Node2D
class_name SoundManager

enum SoundType {
    POSITIONAL,
    NON_POSITIONAL,
}

enum Sounds {

}

onready var _audio_stream_players: Node = $AudioStreamPlayers
onready var _audio_stream_players_2d: Node2D = $AudioStreamPlayer2Ds

func _get_configuration_warning() -> String:
    if _audio_stream_players.get_child_count() == 0 and \
       _audio_stream_players_2d.get_child_count() == 0:
        return 'SoundManager must have at least one audio stream player!'

    for node in _audio_stream_players.get_children():
        if not node is AudioStreamPlayer:
            return 'AudioStreamPlayers must have AudioStreamPlayer children!'

    for node in _audio_stream_players_2d.get_children():
        if not node is AudioStreamPlayer2D:
            return 'AudioStreamPlayer2Ds must have AudioStreamPlayer2D children!'

    return ''

# Plays the sound effect corresponding to the given enum value.
func play(sound_enum: int) -> void:
    pass
