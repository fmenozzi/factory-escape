extends 'res://actors/enemies/enemy_state.gd'

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    turret.get_projectile_spawner().emit_signal('projectile_spawner_destroyed')

    turret.get_animation_player().play('die')

    turret.set_hit_and_hurt_boxes_disabled(true)
    turret.visible = false

func exit(turret: Turret) -> void:
    turret.set_hit_and_hurt_boxes_disabled(false)
    turret.visible = true

func update(turret: Turret, delta: float) -> Dictionary:
    return {'new_state': Turret.State.NO_CHANGE}
