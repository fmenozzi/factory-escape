extends SoundManager
class_name EnemySoundManager

enum Sounds {
    ENEMY_HIT_ORGANIC,
    ENEMY_HIT_MECHANICAL,
    EXPAND_ORGANIC,
    CONTRACT_ORGANIC,
    JUMP_ORGANIC,
    LAND_SOFT_ORGANIC,
    TURRET_SCANNING,
}

onready var _enemy_hit_organic: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitOrganic
onready var _enemy_hit_mechanical: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitMechanical

onready var _expand_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/ExpandOrganic
onready var _contract_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/ContractOrganic
onready var _jump_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/JumpOrganic
onready var _land_soft_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/LandSoftOrganic
onready var _turret_scanning: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/TurretScanning

func play(sound_enum: int) -> void:
    var audio_stream_player := get_player(sound_enum)

    audio_stream_player.play()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.ENEMY_HIT_ORGANIC,
        Sounds.ENEMY_HIT_MECHANICAL,
        Sounds.EXPAND_ORGANIC,
        Sounds.CONTRACT_ORGANIC,
        Sounds.JUMP_ORGANIC,
        Sounds.LAND_SOFT_ORGANIC,
        Sounds.TURRET_SCANNING,
    ])

    match sound_enum:
        Sounds.ENEMY_HIT_ORGANIC:
            return _enemy_hit_organic

        Sounds.ENEMY_HIT_MECHANICAL:
            return _enemy_hit_mechanical

        Sounds.EXPAND_ORGANIC:
            return _expand_organic.get_player()

        Sounds.CONTRACT_ORGANIC:
            return _contract_organic.get_player()

        Sounds.JUMP_ORGANIC:
            return _jump_organic.get_player()

        Sounds.LAND_SOFT_ORGANIC:
            return _land_soft_organic.get_player()

        Sounds.TURRET_SCANNING:
            return _turret_scanning.get_player()

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
            return null

func get_all_visibility_players() -> Array:
    return _audio_stream_players_visibility.get_children()
