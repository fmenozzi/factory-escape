extends Node2D
class_name CentralLock

signal ready_to_turn_on_new_light

enum LockLight {
    SECTOR_ONE = 1,
    SECTOR_TWO = 2,
    SECTOR_THREE = 3,
    SECTOR_FOUR = 4,
    CENTRAL,
}

onready var _lights: Node2D = $LightSprites
onready var _upper_left_animation_player: AnimationPlayer = $LightSprites/UpperLeft/AnimationPlayer
onready var _upper_right_animation_player: AnimationPlayer = $LightSprites/UpperRight/AnimationPlayer
onready var _lower_left_animation_player: AnimationPlayer = $LightSprites/LowerLeft/AnimationPlayer
onready var _lower_right_animation_player: AnimationPlayer = $LightSprites/LowerRight/AnimationPlayer
onready var _central_animation_player: AnimationPlayer = $LightSprites/Central/AnimationPlayer
onready var _sector_one_switch: CentralLockSwitch = $Switches/SectorOneSwitch
onready var _sector_two_switch: CentralLockSwitch = $Switches/SectorTwoSwitch
onready var _sector_three_switch: CentralLockSwitch = $Switches/SectorThreeSwitch
onready var _sector_four_switch: CentralLockSwitch = $Switches/SectorFourSwitch
onready var _closing_door: StaticBody2D = $ClosingDoor
onready var _save_manager: CentralLockSaveManager = $SaveManager

func _ready() -> void:
    for sprite in _lights.get_children():
        assert(sprite is Sprite)
        sprite.modulate.a = 0

    _closing_door.set_closed()

func get_animation_player(light: int) -> AnimationPlayer:
    assert(light in [
        LockLight.SECTOR_ONE,
        LockLight.SECTOR_TWO,
        LockLight.SECTOR_THREE,
        LockLight.SECTOR_FOUR,
        LockLight.CENTRAL,
    ])

    match light:
        LockLight.SECTOR_ONE:
            return _upper_left_animation_player
        LockLight.SECTOR_TWO:
            return _upper_right_animation_player
        LockLight.SECTOR_THREE:
            return _lower_left_animation_player
        LockLight.SECTOR_FOUR:
            return _lower_right_animation_player
        LockLight.CENTRAL:
            return _central_animation_player

    return null

func lights_already_pulsing() -> bool:
    for sector_number in [1, 2, 3, 4]:
        var animation_player := get_animation_player(sector_number)
        if animation_player.is_playing() and animation_player.current_animation == 'pulse':
            return true
    return false

func all_lights_pulsing() -> bool:
    for sector_number in [1, 2, 3, 4]:
        var animation_player := get_animation_player(sector_number)
        if not animation_player.is_playing() or not animation_player.current_animation == 'pulse':
            return false
    return true

func turn_on_light(light: int) -> void:
    assert(light in [
        LockLight.SECTOR_ONE,
        LockLight.SECTOR_TWO,
        LockLight.SECTOR_THREE,
        LockLight.SECTOR_FOUR,
        LockLight.CENTRAL,
    ])

    var animation_player := get_animation_player(light)
    animation_player.play('turn_on')
    animation_player.queue('pulse')

    match light:
        LockLight.SECTOR_ONE:
            _save_manager.sector_one_unlocked = true
        LockLight.SECTOR_TWO:
            _save_manager.sector_two_unlocked = true
        LockLight.SECTOR_THREE:
            _save_manager.sector_three_unlocked = true
        LockLight.SECTOR_FOUR:
            _save_manager.sector_four_unlocked = true

func deactivate_switch(sector_number: int) -> void:
    assert(sector_number in [1, 2, 3, 4])

    match sector_number:
        LockLight.SECTOR_ONE:
            _sector_one_switch.deactivate()
        LockLight.SECTOR_TWO:
            _sector_two_switch.deactivate()
        LockLight.SECTOR_THREE:
            _sector_three_switch.deactivate()
        LockLight.SECTOR_FOUR:
            _sector_four_switch.deactivate()

func get_closing_door() -> StaticBody2D:
    return _closing_door
