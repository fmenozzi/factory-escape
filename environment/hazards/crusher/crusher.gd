extends Node2D

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _dust_puffs: Array = $CrusherHead/DustPuffs.get_children()

func _ready() -> void:
    _animation_player.play('crush_loop')

func _impact() -> void:
    Screenshake.start(Screenshake.Duration.SHORT, Screenshake.Amplitude.SMALL)

    for dust_puff in _dust_puffs:
        dust_puff.emitting = true
