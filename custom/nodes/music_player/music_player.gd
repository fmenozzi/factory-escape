extends Node

enum Music {
    START_GAME,
    FACTORY_BACKGROUND,
    WORLD_BASE,
    WORLD_SECTOR_1,
    WORLD_SECTOR_2,
    WORLD_SECTOR_3,
    WORLD_SECTOR_4,
    WORLD_SECTOR_5,
    ARENA_START,
    ARENA,
    ARENA_END,
    WARDEN_FIGHT_START,
    WARDEN_FIGHT,
    WARDEN_FIGHT_END,
    LAMP_ROOM,
    LAMP_ROOM_SECTOR_5,
    ABILITY_IDLE_LOOP,
}

onready var _players: Array = $AudioPlayers.get_children()
onready var _start_game: AudioStreamPlayerMusic = $AudioPlayers/StartGame
onready var _factory_background: AudioStreamPlayerMusic = $AudioPlayers/FactoryBackground
onready var _world_base: AudioStreamPlayerMusic = $AudioPlayers/WorldBase
onready var _world_sector_1: AudioStreamPlayerMusic = $AudioPlayers/WorldSectorOne
onready var _world_sector_2: AudioStreamPlayerMusic = $AudioPlayers/WorldSectorTwo
onready var _world_sector_3: AudioStreamPlayerMusic = $AudioPlayers/WorldSectorThree
onready var _world_sector_4: AudioStreamPlayerMusic = $AudioPlayers/WorldSectorFour
onready var _world_sector_5: AudioStreamPlayerMusic = $AudioPlayers/WorldSectorFive
onready var _arena_start: AudioStreamPlayerMusic = $AudioPlayers/ArenaStart
onready var _arena: AudioStreamPlayerMusic = $AudioPlayers/Arena
onready var _arena_end: AudioStreamPlayerMusic = $AudioPlayers/ArenaEnd
onready var _warden_fight_start: AudioStreamPlayerMusic = $AudioPlayers/WardenFightStart
onready var _warden_fight: AudioStreamPlayerMusic = $AudioPlayers/WardenFight
onready var _warden_fight_end: AudioStreamPlayerMusic = $AudioPlayers/WardenFightEnd
onready var _lamp_room: AudioStreamPlayerMusic = $AudioPlayers/LampRoom
onready var _lamp_room_sector_5: AudioStreamPlayerMusic = $AudioPlayers/LampRoomSectorFive
onready var _ability_idle_loop: AudioStreamPlayerMusic = $AudioPlayers/AbilityIdleLoop

func _ready() -> void:
    for player in _players:
        if player.bus == 'Master':
            player.bus = 'Music'

func play(music_enum: int) -> void:
    get_player(music_enum).play()

func is_playing(music_enum: int) -> bool:
    return get_player(music_enum).playing

func is_playing_any_of(music_enums: Array) -> bool:
    for music_enum in music_enums:
        if is_playing(music_enum):
            return true
    return false

func stop(music_enum: int) -> void:
    get_player(music_enum).stop()

func stop_all() -> void:
    for player in _players:
        player.stop()

func get_player(music_enum: int) -> AudioStreamPlayerMusic:
    assert(music_enum in [
        Music.START_GAME,
        Music.FACTORY_BACKGROUND,
        Music.WORLD_BASE,
        Music.WORLD_SECTOR_1,
        Music.WORLD_SECTOR_2,
        Music.WORLD_SECTOR_3,
        Music.WORLD_SECTOR_4,
        Music.WORLD_SECTOR_5,
        Music.ARENA_START,
        Music.ARENA,
        Music.ARENA_END,
        Music.WARDEN_FIGHT_START,
        Music.WARDEN_FIGHT,
        Music.WARDEN_FIGHT_END,
        Music.LAMP_ROOM,
        Music.LAMP_ROOM_SECTOR_5,
        Music.ABILITY_IDLE_LOOP,
    ])

    match music_enum:
        Music.START_GAME:
            return _start_game

        Music.FACTORY_BACKGROUND:
            return _factory_background

        Music.WORLD_BASE:
            return _world_base

        Music.WORLD_SECTOR_1:
            return _world_sector_1

        Music.WORLD_SECTOR_2:
            return _world_sector_2

        Music.WORLD_SECTOR_3:
            return _world_sector_3

        Music.WORLD_SECTOR_4:
            return _world_sector_4

        Music.WORLD_SECTOR_5:
            return _world_sector_5

        Music.ARENA_START:
            return _arena_start

        Music.ARENA:
            return _arena

        Music.ARENA_END:
            return _arena_end

        Music.WARDEN_FIGHT_START:
            return _warden_fight_start

        Music.WARDEN_FIGHT:
            return _warden_fight

        Music.WARDEN_FIGHT_END:
            return _warden_fight_end

        Music.LAMP_ROOM:
            return _lamp_room

        Music.LAMP_ROOM_SECTOR_5:
            return _lamp_room_sector_5

        Music.ABILITY_IDLE_LOOP:
            return _ability_idle_loop

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Music player enum value %d does not exist' % music_enum))
            return null

func fade_out(music_enum: int, duration: float) -> void:
    get_player(music_enum).fade_out(duration)

func fade_in(music_enum: int, duration: float, playback_pos: float = 0.0) -> void:
    get_player(music_enum).fade_in(duration, playback_pos)

func cross_fade(music_enum_out: int, music_enum_in: int, duration: float) -> void:
    fade_out(music_enum_out, duration)
    fade_in(music_enum_in, duration)

func cross_fade_synced(music_enum_out: int, music_enum_in: int, duration: float) -> void:
    var playback_position := get_player(music_enum_out).get_playback_position()
    fade_out(music_enum_out, duration)
    fade_in(music_enum_in, duration, playback_position)
