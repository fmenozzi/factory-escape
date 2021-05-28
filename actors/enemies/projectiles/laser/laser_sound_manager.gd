extends VisibilityBasedSoundManager
class_name LaserSoundManager

enum Sounds {
    TELEGRAPH,
    SHOOT,
    WIND_DOWN,
}

onready var _audio_group: VisibilityBasedAudioGroup = $AudioGroups/VisibilityBasedAudioGroup

func play(sound_enum: int) -> void:
    get_player(sound_enum).play()

func stop(sound_enum: int) -> void:
    get_player(sound_enum).stop()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.TELEGRAPH,
        Sounds.SHOOT,
        Sounds.WIND_DOWN,
    ])

    match sound_enum:
        Sounds.TELEGRAPH:
            return _audio_group.get_player_by_name('Telegraph')

        Sounds.SHOOT:
            return _audio_group.get_player_by_name('Shoot')

        Sounds.WIND_DOWN:
            return _audio_group.get_player_by_name('WindDown')

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Laser sound enum value %d does not exist' % sound_enum))
            return null
