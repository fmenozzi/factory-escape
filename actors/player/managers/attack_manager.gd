extends Node2D
class_name AttackManager

onready var _attack_combo_timer: Timer = $AttackComboTimer
onready var _attack_cooldown_timer: Timer = $AttackCooldownTimer

enum CurrentAttack {
    ATTACK_1,
    ATTACK_2,
    ATTACK_3,
}
var _current_attack: int = CurrentAttack.ATTACK_1

func _ready() -> void:
    _attack_combo_timer.one_shot = true
    _attack_combo_timer.wait_time = 0.5

    _attack_cooldown_timer.one_shot = true
    _attack_cooldown_timer.wait_time = 0.5

func get_next_attack_animation() -> String:
    if _attack_combo_timer.is_stopped():
        _attack_combo_timer.start()
        _current_attack = CurrentAttack.ATTACK_1
        return 'attack_1'

    if _current_attack == CurrentAttack.ATTACK_1:
        _attack_combo_timer.start()
        _current_attack = CurrentAttack.ATTACK_2
        return 'attack_2'
    else:
        _attack_combo_timer.stop()
        _attack_cooldown_timer.start()
        return 'attack_3'

func can_attack() -> bool:
    return _attack_cooldown_timer.is_stopped()
