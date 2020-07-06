extends Node2D

enum Speed {
    SLOW,
    FAST,
}

export(float) var initial_delay := 0.0
export(Speed) var speed := Speed.SLOW

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _dust_puffs: Array = $CrusherHead/DustPuffs.get_children()
onready var _visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D

func _ready() -> void:
    yield(get_tree().create_timer(initial_delay), 'timeout')

    match speed:
        Speed.SLOW:
            _animation_player.play('crush_loop_slow')
        Speed.FAST:
            _animation_player.play('crush_loop_fast')

func _impact() -> void:
    if _player_is_near():
        Screenshake.start(Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)

    for dust_puff in _dust_puffs:
        dust_puff.emitting = true

func _player_is_near() -> bool:
    return _visibility_notifier.is_on_screen()
