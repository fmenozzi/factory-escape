extends SoundManager
class_name EnemySoundManager

enum Sounds {
    ENEMY_HIT_ORGANIC,
    ENEMY_HIT_MECHANICAL,
}

onready var _enemy_hit_organic: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitOrganic
onready var _enemy_hit_mechanical: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitMechanical

func play(sound_enum: int) -> void:
    var audio_stream_player := get_player(sound_enum)

    audio_stream_player.play()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.ENEMY_HIT_ORGANIC,
        Sounds.ENEMY_HIT_MECHANICAL,
    ])

    match sound_enum:
        Sounds.ENEMY_HIT_ORGANIC:
            return _enemy_hit_organic

        Sounds.ENEMY_HIT_MECHANICAL:
            return _enemy_hit_mechanical

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
            return null
