extends Node2D

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func start_and_queue_free() -> void:
    _animation_player.play(_get_random_animation())
    yield(_animation_player, 'animation_finished')
    queue_free()

func _get_random_animation() -> String:
    var idx := randi() % 2 + 1
    var anim := 'dust_puff_' + str(idx)
    assert(_animation_player.has_animation(anim))
    return anim
