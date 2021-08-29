extends Node

enum Music {
    FACTORY_BACKGROUND,
    WORLD_BASE,
    ARENA_START,
    ARENA,
    ARENA_END,
    LAMP_ROOM,
}

onready var _players: Array = $AudioPlayers.get_children()
onready var _factory_background: AudioStreamPlayerMusic = $AudioPlayers/FactoryBackground
onready var _world_base: AudioStreamPlayerMusic = $AudioPlayers/WorldBase
onready var _arena_start: AudioStreamPlayerMusic = $AudioPlayers/ArenaStart
onready var _arena: AudioStreamPlayerMusic = $AudioPlayers/Arena
onready var _arena_end: AudioStreamPlayerMusic = $AudioPlayers/ArenaEnd
onready var _lamp_room: AudioStreamPlayerMusic = $AudioPlayers/LampRoom

func _ready() -> void:
    for player in _players:
        if player.bus == 'Master':
            player.bus = 'Music'

func play(music_enum: int) -> void:
    get_player(music_enum).play()

func stop(music_enum: int) -> void:
    get_player(music_enum).stop()

func stop_all() -> void:
    for player in _players:
        player.stop()

func get_player(music_enum: int) -> AudioStreamPlayerMusic:
    assert(music_enum in [
        Music.FACTORY_BACKGROUND,
        Music.WORLD_BASE,
        Music.ARENA_START,
        Music.ARENA,
        Music.ARENA_END,
        Music.LAMP_ROOM,
    ])

    match music_enum:
        Music.FACTORY_BACKGROUND:
            return _factory_background

        Music.WORLD_BASE:
            return _world_base

        Music.ARENA_START:
            return _arena_start

        Music.ARENA:
            return _arena

        Music.ARENA_END:
            return _arena_end

        Music.LAMP_ROOM:
            return _lamp_room

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

func fade_in(music_enum: int, duration: float) -> void:
    get_player(music_enum).fade_in(duration)

func cross_fade(music_enum_out: int, music_enum_in: int, duration: float) -> void:
    fade_out(music_enum_out, duration)
    fade_in(music_enum_in, duration)
