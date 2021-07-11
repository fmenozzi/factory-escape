extends Control

const VIGNETTE_POWER_ENABLED := 0.75
const VIGNETTE_POWER_DISABLED := 0.0
const TWEEN_DURATION := 0.5

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _on_health_changed(old_health: int, new_health: int) -> void:
    if new_health == 1:
        # Activate vignette effect on low health.
        _activate_vignette()

    if old_health <= 1 and new_health > old_health:
        # Deactivate vignette effect once healed.
        _deactivate_vignette()

func _activate_vignette() -> void:
    _animation_player.play('activate')

func _deactivate_vignette() -> void:
    _animation_player.play('deactivate')

