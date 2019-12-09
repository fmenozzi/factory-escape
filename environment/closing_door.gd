extends StaticBody2D

signal door_opened
signal door_closed

const DustPuff := preload('res://sfx/LandingPuff.tscn')

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _collision_shape: CollisionShape2D = $CollisionShape2D

var _is_closed = false

func open() -> void:
    _collision_shape.set_deferred('disabled', true)
    _animation_player.play_backwards('close')
    yield(_animation_player, 'animation_finished')
    _is_closed = false
    emit_signal('door_opened')

func close() -> void:
    _collision_shape.set_deferred('disabled', false)
    _animation_player.play('close')

    # Small dust puff after the door closes.
    yield(_animation_player, 'animation_finished')
    var dust_puff := DustPuff.instance()
    dust_puff.show_behind_parent = false
    Util.spawn_particles(dust_puff, self)

    _is_closed = true
    emit_signal('door_closed')

func is_closed() -> bool:
    return _is_closed