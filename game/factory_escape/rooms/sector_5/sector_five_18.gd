extends RoomFe

onready var _music_trigger: Area2D = $MusicTrigger

func _ready() -> void:
    _music_trigger.connect('body_entered', self, '_trigger_music_change')

func set_music_trigger_active(active: bool) -> void:
    if active:
        _music_trigger.call_deferred('connect', 'body_entered', self, '_trigger_music_change')
    else:
        _music_trigger.call_deferred('disconnect', 'body_entered', self, '_trigger_music_change')

func lamp_reset() -> void:
    set_music_trigger_active(true)

func _trigger_music_change(player: Player) -> void:
    if not player:
        return

    MusicPlayer.cross_fade(
        MusicPlayer.Music.ESCAPE_SEQUENCE_2,
        MusicPlayer.Music.ESCAPE_SEQUENCE_3,
        0.5)

    set_music_trigger_active(false)
