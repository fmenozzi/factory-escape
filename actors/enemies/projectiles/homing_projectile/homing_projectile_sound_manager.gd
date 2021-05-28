extends VisibilityBasedSoundManager
class_name HomingProjectileSoundManager

enum Sounds {
    SPAWN,
    SHOOT,
    FOLLOW,
    IMPACT,
}

onready var _audio_group: VisibilityBasedAudioGroup = $AudioGroups/VisibilityBasedAudioGroup

func play(sound_enum: int) -> void:
    get_player(sound_enum).play()

func stop(sound_enum: int) -> void:
    get_player(sound_enum).stop()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.SPAWN,
        Sounds.SHOOT,
        Sounds.FOLLOW,
        Sounds.IMPACT,
    ])

    match sound_enum:
        Sounds.SPAWN:
            return _audio_group.get_player_by_name('Spawn')

        Sounds.SHOOT:
            return _audio_group.get_player_by_name('Shoot')

        Sounds.FOLLOW:
            return _audio_group.get_player_by_name('Follow')

        Sounds.IMPACT:
            return _audio_group.get_player_by_name('Impact')

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'HomingProjectile sound enum value %d does not exist' % sound_enum))
            return null
