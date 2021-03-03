extends SoundManager
class_name EnemySoundManager

const MAX_DISTANCE_TILES := 11

enum Sounds {
    ENEMY_HIT_ORGANIC,
    ENEMY_HIT_MECHANICAL,
    EXPAND_ORGANIC,
    CONTRACT_ORGANIC,
    JUMP_ORGANIC,
    LAND_SOFT_ORGANIC,
}

onready var _enemy_hit_organic: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitOrganic
onready var _enemy_hit_mechanical: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitMechanical

onready var _expand_organic: AudioStreamPlayer2D = $AudioStreamPlayer2Ds/ExpandOrganic
onready var _contract_organic: AudioStreamPlayer2D = $AudioStreamPlayer2Ds/ContractOrganic
onready var _jump_organic: AudioStreamPlayer2D = $AudioStreamPlayer2Ds/JumpOrganic
onready var _land_soft_organic: AudioStreamPlayer2D = $AudioStreamPlayer2Ds/LandSoftOrganic

func _ready() -> void:
    for player in _audio_stream_players_2d.get_children():
        player.max_distance = Util.TILE_SIZE * MAX_DISTANCE_TILES

func play(sound_enum: int) -> void:
    var audio_stream_player := get_player(sound_enum)

    audio_stream_player.play()

func get_player(sound_enum: int) -> Node:
    assert(sound_enum in [
        Sounds.ENEMY_HIT_ORGANIC,
        Sounds.ENEMY_HIT_MECHANICAL,
        Sounds.EXPAND_ORGANIC,
        Sounds.CONTRACT_ORGANIC,
        Sounds.JUMP_ORGANIC,
        Sounds.LAND_SOFT_ORGANIC,
    ])

    match sound_enum:
        Sounds.ENEMY_HIT_ORGANIC:
            return _enemy_hit_organic

        Sounds.ENEMY_HIT_MECHANICAL:
            return _enemy_hit_mechanical

        Sounds.EXPAND_ORGANIC:
            return _expand_organic

        Sounds.CONTRACT_ORGANIC:
            return _contract_organic

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Sound enum value %d does not exist' % sound_enum))
            return null
