extends Node2D
class_name PlayerSoundManager

enum Sounds {
    WALK,
    JUMP,
    DASH,
    WALL_SLIDE,
    ATTACK,
    GRAPPLE_LAUNCH,
    GRAPPLE_SWING,
    HEAL_STARTED,
    HEAL_SUCCEEDED,
    HEAL_FAILED,
    HEAL_ATTEMPTED_NO_HEALTH_PACKS,
    HIT,
    HAZARD_HIT,
    DIE,
    LAND_SOFT,
    LAND_HARD,
    INTERACT,
    WALK_GRASS,
}

onready var _all_audio_stream_players: Array = $AudioStreamPlayers.get_children()
onready var _walk: AudioStreamPlayer = $AudioStreamPlayers/Walk
onready var _jump: AudioStreamPlayer = $AudioStreamPlayers/Jump
onready var _dash: AudioStreamPlayer = $AudioStreamPlayers/Dash
onready var _wall_slide: AudioStreamPlayer = $AudioStreamPlayers/WallSlide
onready var _attack: AudioStreamPlayer = $AudioStreamPlayers/Attack
onready var _grapple_launch: AudioStreamPlayer = $AudioStreamPlayers/GrappleLaunch
onready var _grapple_swing: AudioStreamPlayer = $AudioStreamPlayers/GrappleSwing
onready var _heal_started: AudioStreamPlayer = $AudioStreamPlayers/HealStarted
onready var _heal_succeeded: AudioStreamPlayer = $AudioStreamPlayers/HealSucceeded
onready var _heal_failed: AudioStreamPlayer = $AudioStreamPlayers/HealFailed
onready var _heal_attempted_no_health_packs: AudioStreamPlayer = $AudioStreamPlayers/HealAttemptedNoHealthPacks
onready var _hit: AudioStreamPlayer = $AudioStreamPlayers/Hit
onready var _hazard_hit: AudioStreamPlayer = $AudioStreamPlayers/HazardHit
onready var _die: AudioStreamPlayer = $AudioStreamPlayers/Die
onready var _land_soft: AudioStreamPlayer = $AudioStreamPlayers/LandSoft
onready var _land_hard: AudioStreamPlayer = $AudioStreamPlayers/LandHard
onready var _interact: AudioStreamPlayer = $AudioStreamPlayers/Interact
onready var _walk_grass: AudioStreamPlayer = $AudioStreamPlayers/WalkGrass

func _ready() -> void:
    for audio_stream_player in _all_audio_stream_players:
        assert(audio_stream_player is AudioStreamPlayer)
        audio_stream_player.bus = 'Effects'

    _die.bus = 'Death'

func set_all_muted(muted: bool) -> void:
    # Since AudioStreamPlayer doesn't have built-in mute functionality (i.e. it
    # can't remember what the pre-mute volume was for when it's time to unmute),
    # simply pause the stream for now.
    for audio_stream_player in _all_audio_stream_players:
        audio_stream_player.stream_paused = muted

func play(sound_enum: int) -> void:
    get_player(sound_enum).play()

func stop(sound_enum: int) -> void:
    # Include the call to seek() to ensure that the sound stops playing when
    # stop() is called. This was not always previously the case, as there were
    # instances where looping audio would continue to play if stop() was called
    # too soon after play().
    var audio_stream_player := get_player(sound_enum)
    audio_stream_player.seek(-1)
    audio_stream_player.stop()

func get_player(sound_enum: int) -> AudioStreamPlayer:
    assert(sound_enum in [
        Sounds.WALK,
        Sounds.JUMP,
        Sounds.DASH,
        Sounds.WALL_SLIDE,
        Sounds.ATTACK,
        Sounds.GRAPPLE_LAUNCH,
        Sounds.GRAPPLE_SWING,
        Sounds.HEAL_STARTED,
        Sounds.HEAL_SUCCEEDED,
        Sounds.HEAL_FAILED,
        Sounds.HEAL_ATTEMPTED_NO_HEALTH_PACKS,
        Sounds.HIT,
        Sounds.HAZARD_HIT,
        Sounds.DIE,
        Sounds.LAND_SOFT,
        Sounds.LAND_HARD,
        Sounds.INTERACT,
        Sounds.WALK_GRASS,
    ])

    match sound_enum:
        Sounds.WALK:
            return _walk

        Sounds.JUMP:
            return _jump

        Sounds.DASH:
            return _dash

        Sounds.WALL_SLIDE:
            return _wall_slide

        Sounds.ATTACK:
            return _attack

        Sounds.GRAPPLE_LAUNCH:
            return _grapple_launch

        Sounds.GRAPPLE_SWING:
            return _grapple_swing

        Sounds.HEAL_STARTED:
            return _heal_started

        Sounds.HEAL_SUCCEEDED:
            return _heal_succeeded

        Sounds.HEAL_FAILED:
            return _heal_failed

        Sounds.HEAL_ATTEMPTED_NO_HEALTH_PACKS:
            return _heal_attempted_no_health_packs

        Sounds.HIT:
            return _hit

        Sounds.HAZARD_HIT:
            return _hazard_hit

        Sounds.DIE:
            return _die

        Sounds.LAND_SOFT:
            return _land_soft

        Sounds.LAND_HARD:
            return _land_hard

        Sounds.INTERACT:
            return _interact

        Sounds.WALK_GRASS:
            return _walk_grass

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Player sound enum value %d does not exist' % sound_enum))
            return null
