extends Control

const HEALTH_TO_TEXTURE := {
    0: preload('res://ui/interface/health_bar/textures/health-0.png'),
    1: preload('res://ui/interface/health_bar/textures/low_health_animation.tres'),
    2: preload('res://ui/interface/health_bar/textures/health-2.png'),
    3: preload('res://ui/interface/health_bar/textures/health-3.png'),
    4: preload('res://ui/interface/health_bar/textures/health-4.png'),
    5: preload('res://ui/interface/health_bar/textures/health-5.png'),
}

const HEALTH_TO_TEXTURE_SECTOR_FIVE := {
    0: preload('res://ui/interface/health_bar/textures/health-0-sector-5.png'),
    1: preload('res://ui/interface/health_bar/textures/low_health_animation_sector_5.tres'),
    2: preload('res://ui/interface/health_bar/textures/health-2-sector-5.png'),
    3: preload('res://ui/interface/health_bar/textures/health-3-sector-5.png'),
    4: preload('res://ui/interface/health_bar/textures/health-4-sector-5.png'),
    5: preload('res://ui/interface/health_bar/textures/health-5-sector-5.png'),
}

onready var _texture: TextureRect = $HealthTexture
onready var _flash_manager: Node = $FlashManager
onready var _tween: Tween = $FadeInTween

var _using_sector_five_texture := false

func set_health(new_health: int) -> void:
    assert(0 <= new_health and new_health <= 5)

    if _using_sector_five_texture:
        _texture.texture = HEALTH_TO_TEXTURE_SECTOR_FIVE[new_health]
    else:
        _texture.texture = HEALTH_TO_TEXTURE[new_health]

func switch_to_sector_5_textures() -> void:
    _using_sector_five_texture = true
    set_health(Util.get_player().get_health().get_current_health())

func flash() -> void:
    _flash_manager.start_flashing()

func fade_in() -> void:
    _tween.remove_all()
    _tween.interpolate_property(self, 'modulate:a', 0, 1, 1.0)
    _tween.start()

func fade_out() -> void:
    _tween.remove_all()
    _tween.interpolate_property(self, 'modulate:a', 1, 0, 1.0)
    _tween.start()

func _on_health_changed(old_health: int, new_health: int) -> void:
    set_health(new_health)
