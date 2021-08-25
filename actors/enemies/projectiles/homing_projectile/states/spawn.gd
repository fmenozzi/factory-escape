extends 'res://actors/enemies/enemy_state.gd'

var _direction := Vector2.ZERO

func enter(projectile: HomingProjectile, previous_state_dict: Dictionary) -> void:
    projectile.get_sound_manager().play(HomingProjectileSoundManager.Sounds.SPAWN)
    projectile.get_animation_player().play('spawn')

    assert('direction' in previous_state_dict)
    _direction = previous_state_dict['direction']

func exit(projectile: HomingProjectile) -> void:
    pass

func update(projectile: HomingProjectile, delta: float) -> Dictionary:
    if not projectile.get_animation_player().is_playing():
        return {
            'new_state': HomingProjectile.State.FOLLOW,
            'direction': _direction,
        }

    return {'new_state': HomingProjectile.State.NO_CHANGE}
