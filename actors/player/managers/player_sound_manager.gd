extends SoundManager
class_name PlayerSoundManager

enum Sounds {
    WALK,
    DASH,
    LAND_SOFT,
    LAND_HARD,
}

onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk
onready var _dash: AudioStreamPlayer = $AudioStreamPlayers/Dash
onready var _land_soft: AudioStreamPlayer = $AudioStreamPlayers/LandSoft
onready var _land_hard: AudioStreamPlayer = $AudioStreamPlayers/LandHard

func play(sound_enum: int) -> void:
    assert(sound_enum in [
        Sounds.WALK,
        Sounds.DASH,
        Sounds.LAND_SOFT,
        Sounds.LAND_HARD,
    ])

    match sound_enum:
        Sounds.WALK:
            _walk.play()

        Sounds.DASH:
            _dash.play()

        Sounds.LAND_SOFT:
            _land_soft.play()

        Sounds.LAND_HARD:
            _land_hard.play()

        _:
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
