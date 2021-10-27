extends Node2D
class_name FragilePlatform

onready var _dust_puff_spawn_positions: Array = $DustPuffSpawnPositions.get_children()
onready var _break_trigger: Area2D = $BreakTrigger
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _break_sound: AudioStreamPlayer = $Break

func _ready() -> void:
    for position2d in _dust_puff_spawn_positions:
        assert(position2d is Position2D)

    reset()

func break_platform() -> void:
    _animation_player.play('break')
    Screenshake.start(
        Screenshake.Duration.SHORT, Screenshake.Amplitude.VERY_SMALL)
    Rumble.start(Rumble.Type.WEAK, 0.3)
    _break_sound.play()

func reset() -> void:
    _break_trigger.connect('body_entered', self, '_on_break_triggered')
    _animation_player.seek(0, true)

func _spawn_dust_puffs() -> void:
    for dust_puff_spawn_position in _dust_puff_spawn_positions:
        Effects.spawn_dust_puff_at(self.to_global(dust_puff_spawn_position.position))

func _on_break_triggered(warden: Warden) -> void:
    if not warden:
        return

    _break_trigger.call_deferred(
        'disconnect', 'body_entered', self, '_on_break_triggered')

    break_platform()
