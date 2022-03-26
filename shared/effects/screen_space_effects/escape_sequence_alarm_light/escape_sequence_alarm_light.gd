extends Control

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _siren: AudioStreamPlayer = $Siren
onready var _siren_volume_tween: Tween = $SirenVolumeTween

func start() -> void:
    _animation_player.play('start')

func stop() -> void:
    _animation_player.play('stop')

    _siren_volume_tween.remove_all()
    _siren_volume_tween.interpolate_property(
        _siren, 'volume_db', _siren.volume_db, -80.0, 1.0)
    _siren_volume_tween.start()
