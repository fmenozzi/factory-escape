extends Node2D
class_name CentralLock

signal ready_to_turn_on_new_light

enum LockLight {
    UPPER_LEFT,
    UPPER_RIGHT,
    LOWER_LEFT,
    LOWER_RIGHT,
    CENTRAL,
}

onready var _lights: Node2D = $LightSprites
onready var _upper_left_animation_player: AnimationPlayer = $LightSprites/UpperLeft/AnimationPlayer
onready var _upper_right_animation_player: AnimationPlayer = $LightSprites/UpperRight/AnimationPlayer
onready var _lower_left_animation_player: AnimationPlayer = $LightSprites/LowerLeft/AnimationPlayer
onready var _lower_right_animation_player: AnimationPlayer = $LightSprites/LowerRight/AnimationPlayer
onready var _central_animation_player: AnimationPlayer = $LightSprites/Central/AnimationPlayer

func _ready() -> void:
    for sprite in _lights.get_children():
        assert(sprite is Sprite)
        sprite.modulate.a = 0

func get_animation_player(light: int) -> AnimationPlayer:
    assert(light in [
        LockLight.UPPER_LEFT,
        LockLight.UPPER_RIGHT,
        LockLight.LOWER_LEFT,
        LockLight.LOWER_RIGHT,
        LockLight.CENTRAL,
    ])

    match light:
        LockLight.UPPER_LEFT:
            return _upper_left_animation_player
        LockLight.UPPER_RIGHT:
            return _upper_right_animation_player
        LockLight.LOWER_LEFT:
            return _lower_left_animation_player
        LockLight.LOWER_RIGHT:
            return _lower_right_animation_player
        LockLight.CENTRAL:
            return _central_animation_player

    return null

func lights_already_pulsing() -> bool:
    var lights := [
        LockLight.UPPER_LEFT,
        LockLight.UPPER_RIGHT,
        LockLight.LOWER_LEFT,
        LockLight.LOWER_RIGHT,
        LockLight.CENTRAL,
    ]

    for light in lights:
        var animation_player := get_animation_player(light)
        if animation_player.is_playing() and animation_player.current_animation == 'pulse':
            return true

    return false

func turn_on_light(light: int) -> void:
    assert(light in [
        LockLight.UPPER_LEFT,
        LockLight.UPPER_RIGHT,
        LockLight.LOWER_LEFT,
        LockLight.LOWER_RIGHT,
        LockLight.CENTRAL,
    ])

    var animation_player := get_animation_player(light)
    animation_player.play('turn_on')
    animation_player.queue('pulse')
