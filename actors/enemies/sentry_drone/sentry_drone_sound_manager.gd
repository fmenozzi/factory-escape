extends VisibilityBasedSoundManager
class_name SentryDroneSoundManager

enum Sounds {
    IDLE,
    MOVE,
    ALERTED,
    UNALERTED,
    BASH_TELEGRAPH,
    BASH,
    BASH_IMPACT,
    BASH_MISSED,
    HIT,
    KILLED,
}

onready var _audio_group: VisibilityBasedAudioGroup = $AudioGroups/VisibilityBasedAudioGroup

func play(sound_enum: int) -> void:
    get_player(sound_enum).play()

func stop(sound_enum: int) -> void:
    get_player(sound_enum).stop()

func get_player(sound_enum: int) -> VisibilityBasedAudioPlayer:
    assert(sound_enum in [
        Sounds.IDLE,
        Sounds.MOVE,
        Sounds.ALERTED,
        Sounds.UNALERTED,
        Sounds.BASH_TELEGRAPH,
        Sounds.BASH,
        Sounds.BASH_IMPACT,
        Sounds.BASH_MISSED,
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

        Sounds.BASH_TELEGRAPH:
            return _audio_group.get_player_by_name('BashTelegraph')

        Sounds.BASH:
            return _audio_group.get_player_by_name('Bash')

        Sounds.BASH_IMPACT:
            return _audio_group.get_player_by_name('BashImpact')

        Sounds.BASH_MISSED:
            return _audio_group.get_player_by_name('BashMissed')

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
                    'SentryDrone sound enum value %d does not exist' % sound_enum))
            return null
