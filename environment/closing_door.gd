extends StaticBody2D

signal door_opened
signal door_closed

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func open() -> void:
    _collision_shape.set_deferred('disabled', true)
    _animation_player.play_backwards('close')
    yield(_animation_player, 'animation_finished')
    emit_signal('door_opened')

func close() -> void:
    _collision_shape.set_deferred('disabled', false)
    _animation_player.play('close')
    yield(_animation_player, 'animation_finished')
    emit_signal('door_closed')