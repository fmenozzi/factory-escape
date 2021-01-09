tool
extends Node2D
class_name SoundManager

enum Sounds {
    PLAYER_WALK,
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

func _ready() -> void:
    var all_audio_stream_players := []

    for audio_stream_player in _audio_stream_players.get_children():
        assert(audio_stream_player is AudioStreamPlayer)
        all_audio_stream_players.append(audio_stream_player)

    for audio_stream_player in _audio_stream_players_2d.get_children():
        assert(audio_stream_player is AudioStreamPlayer2D)
        all_audio_stream_players.append(audio_stream_player)

    for audio_stream_player in all_audio_stream_players:
        audio_stream_player.bus = 'Effects'
