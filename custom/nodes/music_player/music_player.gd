extends Node

enum Music {
    FACTORY_BACKGROUND,
}

onready var _players: Array = $AudioPlayers.get_children()
onready var _factory_background: AudioStreamPlayer = $AudioPlayers/FactoryBackground

func _ready() -> void:
    for player in _players:
        player.bus = 'Music'

func play(music_enum: int) -> void:
    get_player(music_enum).play()

func get_player(music_enum: int) -> AudioStreamPlayer:
    assert(music_enum in [
        Music.FACTORY_BACKGROUND,
    ])

    match music_enum:
        Music.FACTORY_BACKGROUND:
            return _factory_background

        _:
            # Simply report the error here immediately instead of deferring to
            # the caller, as the response would basically always be the same.
            Error.report_if_error(
                ErrorPlusMessage.new(
                    ERR_DOES_NOT_EXIST,
                    'Music player enum value %d does not exist' % music_enum))
            return null
