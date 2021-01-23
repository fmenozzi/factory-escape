extends SoundManager
class_name PlayerSoundManager

enum Sounds {
    WALK,
    JUMP,
    DASH,
    ATTACK_1,
    ATTACK_2,
    ATTACK_3,
    LAND_SOFT,
    LAND_HARD,
}

onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk
onready var _jump: AudioStreamPlayer = $AudioStreamPlayers/Jump
onready var _dash: AudioStreamPlayer = $AudioStreamPlayers/Dash
onready var _attack: AudioStreamPlayer = $AudioStreamPlayers/Attack
onready var _land_soft: AudioStreamPlayer = $AudioStreamPlayers/LandSoft
onready var _land_hard: AudioStreamPlayer = $AudioStreamPlayers/LandHard

func play(sound_enum: int) -> void:
    var audio_stream_player := get_player(sound_enum)

    audio_stream_player.play()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.WALK,
        Sounds.JUMP,
        Sounds.DASH,
        Sounds.ATTACK_1,
        Sounds.ATTACK_2,
        Sounds.ATTACK_3,
        Sounds.LAND_SOFT,
        Sounds.LAND_HARD,
    ])

    match sound_enum:
        Sounds.WALK:
            return _walk

        Sounds.JUMP:
            return _jump

        Sounds.DASH:
            return _dash

        Sounds.ATTACK_1:
            _attack.pitch_scale = 1
            return _attack

        Sounds.ATTACK_2:
            _attack.pitch_scale = 1.1
            return _attack

        Sounds.ATTACK_3:
            _attack.pitch_scale = 1.2
            return _attack

        Sounds.LAND_SOFT:
            return _land_soft

        Sounds.LAND_HARD:
            return _land_hard

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
            return null
