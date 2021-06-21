extends VisibilityBasedSoundManager
class_name RangedSentryDroneSoundManager

enum Sounds {
    IDLE,
    MOVE,
    ALERTED,
    UNALERTED,
    HIT,
    KILLED,
}

onready var _audio_group: VisibilityBasedAudioGroup = $AudioGroups/VisibilityBasedAudioGroup

func play(sound_enum: int) -> void:
    get_player(sound_enum).play()

func stop(sound_enum: int) -> void:
    get_player(sound_enum).stop()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.IDLE,
        Sounds.MOVE,
        Sounds.ALERTED,
        Sounds.UNALERTED,
        Sounds.HIT,
        Sounds.KILLED,
    ])

    match sound_enum:
        Sounds.IDLE:
            return _audio_group.get_player_by_name('Idle')

        Sounds.MOVE:
            return _audio_group.get_player_by_name('Move')

        Sounds.ALERTED:
            return _audio_group.get_player_by_name('Alerted')

        Sounds.UNALERTED:
            return _audio_group.get_player_by_name('Unalerted')

        Sounds.HIT:
            return _audio_group.get_player_by_name('Hit')

        Sounds.KILLED:
            return _audio_group.get_player_by_name('Killed')

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'RangedSentryDrone sound enum value %d does not exist' % sound_enum))
            return null
