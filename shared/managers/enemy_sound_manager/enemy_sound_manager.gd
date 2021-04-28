extends SoundManager
class_name EnemySoundManager

enum Sounds {
    ENEMY_HIT_ORGANIC,
    ENEMY_HIT_MECHANICAL,
    ENEMY_KILLED_ORGANIC,
    ENEMY_KILLED_MECHANICAL,
    EXPAND_ORGANIC,
    CONTRACT_ORGANIC,
    JUMP_ORGANIC,
    LAND_SOFT_ORGANIC,
    TURRET_SCANNING,
    SENTRY_DRONE_BASH_TELEGRAPH,
    SENTRY_DRONE_BASH,
    SENTRY_DRONE_BASH_IMPACT,
    SENTRY_DRONE_BASH_MISSED,
    HOMING_PROJECTILE_SPAWN,
    HOMING_PROJECTILE_SHOOT,
    HOMING_PROJECTILE_FOLLOW,
    HOMING_PROJECTILE_IMPACT,
    STICKY_DRONE_WALK,
    STICKY_DRONE_EXPAND,
    STICKY_DRONE_CONTRACT,
    DRONE_IDLE,
    DRONE_MOVE,
    LASER_TELEGRAPH,
    LASER_SHOOT,
    LASER_WIND_DOWN,
}

onready var _enemy_hit_organic: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitOrganic
onready var _enemy_hit_mechanical: AudioStreamPlayer = $AudioStreamPlayers/EnemyHitMechanical
onready var _enemy_killed_organic: AudioStreamPlayer = $AudioStreamPlayers/EnemyKilledOrganic
onready var _enemy_killed_mechanical: AudioStreamPlayer = $AudioStreamPlayers/EnemyKilledMechanical

onready var _expand_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/ExpandOrganic
onready var _contract_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/ContractOrganic
onready var _jump_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/JumpOrganic
onready var _land_soft_organic: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/LandSoftOrganic
onready var _turret_scanning: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/TurretScanning
onready var _sentry_drone_bash_telegraph: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/SentryDroneBashTelegraph
onready var _sentry_drone_bash: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/SentryDroneBash
onready var _sentry_drone_bash_impact: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/SentryDroneBashImpact
onready var _sentry_drone_bash_missed: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/SentryDroneBashMissed
onready var _homing_projectile_spawn: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/HomingProjectileSpawn
onready var _homing_projectile_shoot: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/HomingProjectileShoot
onready var _homing_projectile_follow: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/HomingProjectileFollow
onready var _homing_projectile_impact: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/HomingProjectileImpact
onready var _sticky_drone_walk: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/StickyDroneWalk
onready var _sticky_drone_expand: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/StickyDroneExpand
onready var _sticky_drone_contract: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/StickyDroneContract
onready var _drone_idle: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/DroneIdle
onready var _drone_move: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/DroneMove
onready var _laser_telegraph: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/LaserTelegraph
onready var _laser_shoot: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/LaserShoot
onready var _laser_wind_down: AudioStreamPlayerVisibility = $AudioStreamPlayersVisibility/LaserWindDown

func play(sound_enum: int) -> void:
    var audio_stream_player := get_player(sound_enum)

    audio_stream_player.play()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.ENEMY_HIT_ORGANIC,
        Sounds.ENEMY_HIT_MECHANICAL,
        Sounds.ENEMY_KILLED_ORGANIC,
        Sounds.ENEMY_KILLED_MECHANICAL,
        Sounds.EXPAND_ORGANIC,
        Sounds.CONTRACT_ORGANIC,
        Sounds.JUMP_ORGANIC,
        Sounds.LAND_SOFT_ORGANIC,
        Sounds.TURRET_SCANNING,
        Sounds.SENTRY_DRONE_BASH_TELEGRAPH,
        Sounds.SENTRY_DRONE_BASH,
        Sounds.SENTRY_DRONE_BASH_IMPACT,
        Sounds.SENTRY_DRONE_BASH_MISSED,
        Sounds.HOMING_PROJECTILE_SPAWN,
        Sounds.HOMING_PROJECTILE_SHOOT,
        Sounds.HOMING_PROJECTILE_FOLLOW,
        Sounds.HOMING_PROJECTILE_IMPACT,
        Sounds.STICKY_DRONE_WALK,
        Sounds.STICKY_DRONE_EXPAND,
        Sounds.STICKY_DRONE_CONTRACT,
        Sounds.DRONE_IDLE,
        Sounds.DRONE_MOVE,
        Sounds.LASER_TELEGRAPH,
        Sounds.LASER_SHOOT,
        Sounds.LASER_WIND_DOWN,
    ])

    match sound_enum:
        Sounds.ENEMY_HIT_ORGANIC:
            return _enemy_hit_organic

        Sounds.ENEMY_HIT_MECHANICAL:
            return _enemy_hit_mechanical

        Sounds.ENEMY_KILLED_ORGANIC:
            return _enemy_killed_organic

        Sounds.ENEMY_KILLED_MECHANICAL:
            return _enemy_killed_mechanical

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

        Sounds.SENTRY_DRONE_BASH_TELEGRAPH:
            return _sentry_drone_bash_telegraph.get_player()

        Sounds.SENTRY_DRONE_BASH:
            return _sentry_drone_bash.get_player()

        Sounds.SENTRY_DRONE_BASH_IMPACT:
            return _sentry_drone_bash_impact.get_player()

        Sounds.SENTRY_DRONE_BASH_MISSED:
            return _sentry_drone_bash_missed.get_player()

        Sounds.HOMING_PROJECTILE_SPAWN:
            return _homing_projectile_spawn.get_player()

        Sounds.HOMING_PROJECTILE_SHOOT:
            return _homing_projectile_shoot.get_player()

        Sounds.HOMING_PROJECTILE_FOLLOW:
            return _homing_projectile_follow.get_player()

        Sounds.HOMING_PROJECTILE_IMPACT:
            return _homing_projectile_impact.get_player()

        Sounds.STICKY_DRONE_WALK:
            return _sticky_drone_walk.get_player()

        Sounds.STICKY_DRONE_EXPAND:
            return _sticky_drone_expand.get_player()

        Sounds.STICKY_DRONE_CONTRACT:
            return _sticky_drone_contract.get_player()

        Sounds.DRONE_IDLE:
            return _drone_idle.get_player()

        Sounds.DRONE_MOVE:
            return _drone_move.get_player()

        Sounds.LASER_TELEGRAPH:
            return _laser_telegraph.get_player()

        Sounds.LASER_SHOOT:
            return _laser_shoot.get_player()

        Sounds.LASER_WIND_DOWN:
            return _laser_wind_down.get_player()

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
