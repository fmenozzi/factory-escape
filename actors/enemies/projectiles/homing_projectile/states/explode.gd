extends 'res://actors/enemies/enemy_state.gd'

func enter(projectile: HomingProjectile, previous_state_dict: Dictionary) -> void:
    # Disable the projectile's hitbox.
    projectile.get_hitbox_collision_shape().set_deferred('disabled', true)

    var sound_manager := projectile.get_sound_manager()
    sound_manager.stop(HomingProjectileSoundManager.Sounds.FOLLOW)
    sound_manager.play(HomingProjectileSoundManager.Sounds.IMPACT)

    # Wait for explode animation to finish.
    var animation_player := projectile.get_animation_player()
    animation_player.play('explode')
    yield(animation_player, 'animation_finished')

    # Wait for the trail particles to disappear, since they last a few seconds.
    yield(get_tree().create_timer(projectile.get_trail_particles().lifetime), 'timeout')

    projectile.queue_free()

func exit(projectile: HomingProjectile) -> void:
    pass

func update(projectile: HomingProjectile, delta: float) -> Dictionary:
    return {'new_state': HomingProjectile.State.NO_CHANGE}
