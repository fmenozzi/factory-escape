extends Node2D
class_name LaserEmitterGroup

onready var _laser_emitters: Array = $LaserEmitters.get_children()
onready var _audio_group: VisibilityBasedAudioGroup = $VisibilityBasedAudioGroup
onready var _timer: Timer = $ShootTimer

var _is_active := true

func _ready() -> void:
    assert(not _laser_emitters.empty())
    for laser_emitter in _laser_emitters:
        assert(laser_emitter is LaserEmitter)
        var laser: Laser = laser_emitter.get_laser()
        laser.set_enable_audio(false)
        laser.connect('audio_playback_requested', self, '_play_laser_audio')

    _timer.one_shot = false
    _timer.wait_time = 4.0
    _timer.connect('timeout', self, '_shoot')

func pause() -> void:
    _timer.stop()

    _audio_group.set_muted(true)

    for laser_emitter in _laser_emitters:
        laser_emitter.pause()

func resume() -> void:
    if not _is_active:
        return

    _audio_group.set_muted(false)

    _timer.start()

    for laser_emitter in _laser_emitters:
        laser_emitter.resume()

    _shoot()

func show_visuals() -> void:
    pass

func hide_visuals() -> void:
    pass

func deactivate() -> void:
    _is_active = false

    _timer.stop()
    _timer.disconnect('timeout', self, '_shoot')

func _shoot() -> void:
    for laser_emitter in _laser_emitters:
        laser_emitter.shoot()

func _play_laser_audio(track: int) -> void:
    assert(track in [
        LaserSoundManager.Sounds.TELEGRAPH,
        LaserSoundManager.Sounds.SHOOT,
        LaserSoundManager.Sounds.WIND_DOWN,
    ])

    match track:
        LaserSoundManager.Sounds.TELEGRAPH:
            _audio_group.get_player_by_name('Telegraph').play()
        LaserSoundManager.Sounds.SHOOT:
            _audio_group.get_player_by_name('Shoot').play()
        LaserSoundManager.Sounds.WIND_DOWN:
            _audio_group.get_player_by_name('WindDown').play()
