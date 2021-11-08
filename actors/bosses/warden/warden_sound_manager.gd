extends VisibilityBasedSoundManager
class_name WardenSoundManager

enum Sounds {
    INTRO_LAND,
    INTRO_UNCROUCH,
    TAKEOFF,
    LAND,
    CHARGE_TELEGRAPH,
    CHARGE_STEP,
    CHARGE_SLIDE,
    CHARGE_IMPACT,
    LIGHTNING_FLOOR_TELEGRAPH_CROUCH,
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
        Sounds.TAKEOFF,
        Sounds.LAND,
        Sounds.CHARGE_TELEGRAPH,
        Sounds.CHARGE_STEP,
        Sounds.CHARGE_SLIDE,
        Sounds.CHARGE_IMPACT,
        Sounds.LIGHTNING_FLOOR_TELEGRAPH_CROUCH,
        Sounds.HIT,
        Sounds.KILLED,
    ])

    match sound_enum:
        Sounds.INTRO_LAND:
            return _audio_group.get_player_by_name('IntroLand')

        Sounds.INTRO_UNCROUCH:
            return _audio_group.get_player_by_name('IntroUncrouch')

        Sounds.TAKEOFF:
            return _audio_group.get_player_by_name('Takeoff')

        Sounds.LAND:
            return _audio_group.get_player_by_name('Land')

        Sounds.CHARGE_TELEGRAPH:
            return _audio_group.get_player_by_name('ChargeTelegraph')

        Sounds.CHARGE_STEP:
            return _audio_group.get_player_by_name('ChargeStep')

        Sounds.CHARGE_SLIDE:
            return _audio_group.get_player_by_name('ChargeSlide')

        Sounds.CHARGE_IMPACT:
            return _audio_group.get_player_by_name('ChargeImpact')

        Sounds.LIGHTNING_FLOOR_TELEGRAPH_CROUCH:
            return _audio_group.get_player_by_name('LightningFloorTelegraphCrouch')

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
