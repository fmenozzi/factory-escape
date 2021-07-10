extends Control

const HEALTH_TO_TEXTURE := {
    0: preload('res://ui/interface/health_bar/textures/health-0.png'),
    1: preload('res://ui/interface/health_bar/textures/health-1.png'),
    2: preload('res://ui/interface/health_bar/textures/health-2.png'),
    3: preload('res://ui/interface/health_bar/textures/health-3.png'),
    4: preload('res://ui/interface/health_bar/textures/health-4.png'),
    5: preload('res://ui/interface/health_bar/textures/health-5.png'),
}

onready var _texture: TextureRect = $HealthTexture

func set_health(new_health: int) -> void:
    assert(0 <= new_health and new_health <= 5)

    _texture.texture = HEALTH_TO_TEXTURE[new_health]

func _on_health_changed(old_health: int, new_health: int) -> void:
    set_health(new_health)
