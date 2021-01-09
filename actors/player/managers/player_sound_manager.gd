extends SoundManager
class_name PlayerSoundManager

onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk

func play(sound_enum: int) -> void:
    assert(sound_enum in [
        Sounds.PLAYER_WALK,
    ])

    match sound_enum:
        Sounds.PLAYER_WALK:
            _walk.play()

        _:
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
