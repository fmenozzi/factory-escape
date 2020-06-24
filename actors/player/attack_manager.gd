extends Node2D
class_name AttackManager

onready var _attack_combo_timer: Timer = $AttackComboTimer

func _ready() -> void:
    _attack_combo_timer.one_shot = true
    _attack_combo_timer.wait_time = 0.5

func get_next_attack_animation() -> String:
    # Attack using appropriate animation, depending on how much time has passed
    # since the last attack.
    if _attack_combo_timer.is_stopped():
        _attack_combo_timer.start()
        return 'attack_1'
    else:
        _attack_combo_timer.stop()
        return 'attack_2'
