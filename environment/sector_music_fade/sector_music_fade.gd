extends Node2D
class_name SectorMusicFade

export(MusicPlayer.Music) var sector_track: int = MusicPlayer.Music.WORLD_SECTOR_1

const FADE_DURATION := 0.5

onready var _fade_in_area: Area2D = $FadeInSectorTrack
onready var _fade_out_area: Area2D = $FadeOutSectorTrack

func _ready() -> void:
    _fade_in_area.connect('body_entered', self, '_fade_in_sector_track')
    _fade_out_area.connect('body_entered', self, '_fade_out_sector_track')

func _fade_in_sector_track(player: Player) -> void:
    if not player:
        return

    if _playing_sector_track():
        return

    MusicPlayer.cross_fade_synced(
        MusicPlayer.Music.WORLD_BASE, sector_track, FADE_DURATION)

func _fade_out_sector_track(player: Player) -> void:
    if not player:
        return

    if not _playing_sector_track():
        return

    MusicPlayer.cross_fade_synced(
        sector_track, MusicPlayer.Music.WORLD_BASE, FADE_DURATION)

func _playing_sector_track() -> bool:
    var sector_track_player := MusicPlayer.get_player(sector_track)

    return sector_track_player.playing and sector_track_player.volume_db > -80.0
