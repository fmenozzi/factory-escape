extends Control

const HEALTH_TO_TEXTURE := {
    0: preload('res://ui/interface/health_bar/textures/health-0.png'),
    1: preload('res://ui/interface/health_bar/textures/low_health_animation.tres'),
    2: preload('res://ui/interface/health_bar/textures/health-2.png'),
    3: preload('res://ui/interface/health_bar/textures/health-3.png'),
    4: preload('res://ui/interface/health_bar/textures/health-4.png'),
    5: preload('res://ui/interface/health_bar/textures/health-5.png'),
}

onready var _texture: TextureRect = $HealthTexture
onready var _flash_manager: Node = $FlashManager
onready var _tween: Tween = $FadeInTween

func set_health(new_health: int) -> void:
    assert(0 <= new_health and new_health <= 5)

    _texture.texture = HEALTH_TO_TEXTURE[new_health]

func flash() -> void:
    _flash_manager.start_flashing()

func fade_in() -> void:
    _tween.remove_all()
    _tween.interpolate_property(self, 'modulate:a', 0, 1, 1.0)
    _tween.start()

func _on_health_changed(old_health: int, new_health: int) -> void:
    set_health(new_health)
