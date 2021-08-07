extends Node2D

enum Speed {
    SLOW,
    FAST,
}

export(float) var initial_delay := 0.0
export(Speed) var speed := Speed.SLOW

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _dust_puff_spawn_positions: Array = $CrusherHead/DustPuffSpawnPositions.get_children()
onready var _visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D
onready var _windup_sound_slow: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/Windup
onready var _windup_sound_fast: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/WindupFast
onready var _impact_sound: VisibilityBasedAudioPlayer = $VisibilityBasedAudioGroup/AudioPlayers/Impact

var _animation_name := ''

var _first_time_resumed := true
var _yielding := false

func _ready() -> void:
    match speed:
        Speed.SLOW:
            _animation_name = 'crush_loop_slow'
        Speed.FAST:
            _animation_name = 'crush_loop_fast'

func pause() -> void:
    _animation_player.stop(false)

func resume() -> void:
    if _yielding:
        return

    if _first_time_resumed:
        _yielding = true
        yield(get_tree().create_timer(initial_delay), 'timeout')
        _yielding = false

        _first_time_resumed = false

    _animation_player.play(_animation_name)

func _windup_slow() -> void:
    _windup_sound_slow.play()

func _windup_fast() -> void:
    _windup_sound_fast.play()

func _impact() -> void:
    if _player_is_near():
        Screenshake.start(Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)

    _impact_sound.play()

    for dust_puff_spawn_position in _dust_puff_spawn_positions:
        Effects.spawn_dust_puff_at(self.to_global(dust_puff_spawn_position.position))

func _player_is_near() -> bool:
    return _visibility_notifier.is_on_screen()
