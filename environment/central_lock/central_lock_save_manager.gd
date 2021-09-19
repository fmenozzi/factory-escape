extends Node
class_name CentralLockSaveManager

onready var _central_lock = get_parent()
onready var _save_key: String = get_parent().get_path()

var sector_one_unlocked := false
var sector_two_unlocked := false
var sector_three_unlocked := false
var sector_four_unlocked := false

func get_save_data() -> Array:
    return [_save_key, {
        'sector_one_unlocked': sector_one_unlocked,
        'sector_two_unlocked': sector_two_unlocked,
        'sector_three_unlocked': sector_three_unlocked,
        'sector_four_unlocked': sector_four_unlocked,
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var central_lock_save_data: Dictionary = all_save_data[_save_key]
    assert('sector_one_unlocked' in central_lock_save_data)
    assert('sector_two_unlocked' in central_lock_save_data)
    assert('sector_three_unlocked' in central_lock_save_data)
    assert('sector_four_unlocked' in central_lock_save_data)

    sector_one_unlocked = central_lock_save_data['sector_one_unlocked']
    sector_two_unlocked = central_lock_save_data['sector_two_unlocked']
    sector_three_unlocked = central_lock_save_data['sector_three_unlocked']
    sector_four_unlocked = central_lock_save_data['sector_four_unlocked']

    var unlocked_animation_players := []
    if sector_one_unlocked:
        unlocked_animation_players.append(
            _central_lock.get_animation_player(_central_lock.LockLight.SECTOR_ONE))
        _central_lock.deactivate_switch(_central_lock.LockLight.SECTOR_ONE)
    if sector_two_unlocked:
        unlocked_animation_players.append(
            _central_lock.get_animation_player(_central_lock.LockLight.SECTOR_TWO))
        _central_lock.deactivate_switch(_central_lock.LockLight.SECTOR_TWO)
    if sector_three_unlocked:
        unlocked_animation_players.append(
            _central_lock.get_animation_player(_central_lock.LockLight.SECTOR_THREE))
        _central_lock.deactivate_switch(_central_lock.LockLight.SECTOR_THREE)
    if sector_four_unlocked:
        unlocked_animation_players.append(
            _central_lock.get_animation_player(_central_lock.LockLight.SECTOR_FOUR))
        _central_lock.deactivate_switch(_central_lock.LockLight.SECTOR_FOUR)

    if sector_one_unlocked and sector_two_unlocked and sector_three_unlocked and sector_four_unlocked:
        unlocked_animation_players.append(
            _central_lock.get_animation_player(_central_lock.LockLight.CENTRAL))
        _central_lock.get_closing_door().set_opened()

    for animation_player in unlocked_animation_players:
        animation_player.play('pulse')
