extends Control

const VIGNETTE_POWER_ENABLED := 0.75
const VIGNETTE_POWER_DISABLED := 0.0
const TWEEN_DURATION := 0.5

onready var _shader_material: ShaderMaterial = $ColorRect.get_material()
onready var _tween: Tween = $VignettePowerTween

func _on_health_changed(old_health: int, new_health: int) -> void:
    if new_health == 1:
        # Activate vignette effect on low health.
        _tween_vignette_power(VIGNETTE_POWER_DISABLED, VIGNETTE_POWER_ENABLED)

    if old_health <= 1 and new_health > old_health:
        # Deactivate vignette effect once healed.
        _tween_vignette_power(VIGNETTE_POWER_ENABLED, VIGNETTE_POWER_DISABLED)

func _tween_vignette_power(old: float, new: float) -> void:
    _tween.remove_all()
    _tween.interpolate_property(
        _shader_material, 'shader_param/vignette_power', old, new,
        TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
    _tween.start()
