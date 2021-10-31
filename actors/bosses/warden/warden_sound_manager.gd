extends VisibilityBasedSoundManager
class_name WardenSoundManager

enum Sounds {
    INTRO_LAND,
    INTRO_UNCROUCH,
    CHARGE_TELEGRAPH,
    CHARGE_IMPACT,
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
        Sounds.INTRO_LAND,
        Sounds.INTRO_UNCROUCH,
        Sounds.CHARGE_TELEGRAPH,
        Sounds.CHARGE_IMPACT,
        Sounds.HIT,
        Sounds.KILLED,
    ])

    match sound_enum:
        Sounds.INTRO_LAND:
            return _audio_group.get_player_by_name('IntroLand')

        Sounds.INTRO_UNCROUCH:
            return _audio_group.get_player_by_name('IntroUncrouch')

        Sounds.CHARGE_TELEGRAPH:
            return _audio_group.get_player_by_name('ChargeTelegraph')

        Sounds.CHARGE_IMPACT:
            return _audio_group.get_player_by_name('ChargeImpact')

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