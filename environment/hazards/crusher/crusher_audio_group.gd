extends Node2D

onready var _crushers: Array = $Crushers.get_children()
onready var _audio_group: VisibilityBasedAudioGroup = $VisibilityBasedAudioGroup
onready var _per_sound_timers := {
    'Windup':     $SoundTimers/Windup,
    'WindupFast': $SoundTimers/WindupFast,
    'Impact':     $SoundTimers/Impact
}

func _ready() -> void:
    for crusher in _crushers:
        crusher.connect('windup', self, '_play_sound', ['Windup'])
        crusher.connect('windup_fast', self, '_play_sound', ['WindupFast'])
        crusher.connect('impact', self, '_play_sound', ['Impact'])

func pause() -> void:
    for crusher in _crushers:
        crusher.pause()

func resume() -> void:
    for crusher in _crushers:
        crusher.resume()

func show_visuals() -> void:
    for crusher in _crushers:
        crusher.show_visuals()

func hide_visuals() -> void:
    for crusher in _crushers:
        crusher.hide_visuals()

func _play_sound(audio_player_name: String) -> void:
    assert(audio_player_name in ['Windup', 'WindupFast', 'Impact'])

    var audio_player := _audio_group.get_player_by_name(audio_player_name)
    var audio_timer: Timer = _per_sound_timers[audio_player_name]
    if audio_timer.is_stopped():
        audio_player.play()
        audio_timer.start()
