extends Node2D
class_name AttackManager

onready var _attack_combo_timer: Timer = $AttackComboTimer
onready var _attack_cooldown_timer: Timer = $AttackCooldownTimer

func _ready() -> void:
    _attack_combo_timer.one_shot = true
    _attack_combo_timer.wait_time = 0.5

    _attack_cooldown_timer.one_shot = true
    _attack_cooldown_timer.wait_time = 0.5

func get_next_attack_animation() -> String:
    # Attack using appropriate animation, depending on how much time has passed
    # since the last attack.
    if _attack_combo_timer.is_stopped():
        _attack_combo_timer.start()
        return 'attack_1'
    else:
        _attack_combo_timer.stop()
        _attack_cooldown_timer.start()
        return 'attack_2'

func can_attack() -> bool:
    return _attack_cooldown_timer.is_stopped()
