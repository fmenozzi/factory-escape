extends SoundManager
class_name PlayerSoundManager

enum Sounds {
    WALK,
    LAND_SOFT,
}

onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk
onready var _land_soft: AudioStreamPlayer = $AudioStreamPlayers/LandSoft

func play(sound_enum: int) -> void:
    assert(sound_enum in [
        Sounds.WALK,
        Sounds.LAND_SOFT,
    ])

    match sound_enum:
        Sounds.WALK:
            _walk.play()

        Sounds.LAND_SOFT:
            _land_soft.play()

        _:
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
