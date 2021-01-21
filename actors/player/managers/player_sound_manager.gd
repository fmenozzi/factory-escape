extends SoundManager
class_name PlayerSoundManager

enum Sounds {
    WALK,
    JUMP,
    DASH,
    ATTACK_1,
    ATTACK_2,
    ATTACK_3,
    LAND_SOFT,
    LAND_HARD,
}

onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk
onready var _jump: AudioStreamPlayer = $AudioStreamPlayers/Jump
onready var _dash: AudioStreamPlayer = $AudioStreamPlayers/Dash
onready var _attack: AudioStreamPlayer = $AudioStreamPlayers/Attack
onready var _land_soft: AudioStreamPlayer = $AudioStreamPlayers/LandSoft
onready var _land_hard: AudioStreamPlayer = $AudioStreamPlayers/LandHard

func play(sound_enum: int) -> void:
    assert(sound_enum in [
        Sounds.WALK,
        Sounds.JUMP,
        Sounds.DASH,
        Sounds.ATTACK_1,
        Sounds.ATTACK_2,
        Sounds.ATTACK_3,
        Sounds.LAND_SOFT,
        Sounds.LAND_HARD,
    ])

    match sound_enum:
        Sounds.WALK:
            _walk.play()

        Sounds.JUMP:
            _jump.play()

        Sounds.DASH:
            _dash.play()

        Sounds.ATTACK_1:
            _attack.pitch_scale = 1
            _attack.play()

        Sounds.ATTACK_2:
            _attack.pitch_scale = 1.1
            _attack.play()

        Sounds.ATTACK_3:
            _attack.pitch_scale = 1.2
            _attack.play()

        Sounds.LAND_SOFT:
            _land_soft.play()

        Sounds.LAND_HARD:
            _land_hard.play()

        _:
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
