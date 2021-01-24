extends SoundManager
class_name PlayerSoundManager

enum Sounds {
    WALK,
    JUMP,
    DASH,
    WALL_SLIDE,
    ATTACK,
    HIT,
    LAND_SOFT,
    LAND_HARD,
}

onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk
onready var _jump: AudioStreamPlayer = $AudioStreamPlayers/Jump
onready var _dash: AudioStreamPlayer = $AudioStreamPlayers/Dash
onready var _wall_slide: AudioStreamPlayer = $AudioStreamPlayers/WallSlide
onready var _attack: AudioStreamPlayer = $AudioStreamPlayers/Attack
onready var _hit: AudioStreamPlayer = $AudioStreamPlayers/Hit
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
        Sounds.WALL_SLIDE,
        Sounds.ATTACK,
        Sounds.HIT,
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

        Sounds.WALL_SLIDE:
            return _wall_slide

        Sounds.ATTACK:
            return _attack

        Sounds.HIT:
            return _hit

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
