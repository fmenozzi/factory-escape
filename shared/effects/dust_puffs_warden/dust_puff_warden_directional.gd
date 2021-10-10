extends Node2D

onready var _sprite: Sprite = $Sprite
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func start_and_queue_free(direction: int) -> void:
    assert(direction in [Util.Direction.LEFT, Util.Direction.RIGHT])
    _sprite.flip_h = (direction == Util.Direction.LEFT)
    _animation_player.play('dust_puff_warden_directional')
    yield(_animation_player, 'animation_finished')
    queue_free()
