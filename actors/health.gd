extends Node

signal health_changed(old_health, new_health)

export(int) var MAX_HEALTH = 3

var _current_health: int = MAX_HEALTH

enum Status {
    NONE,
    INVINCIBLE,
}
var _current_status: int = Status.NONE

func take_damage(damage_amount: int) -> void:
    if _current_status == Status.INVINCIBLE:
        return

    var old_health := _current_health
    var new_health := max(_current_health - damage_amount, 0)

    _current_health = new_health

    emit_signal('health_changed', old_health, new_health)

func heal(heal_amount: int) -> void:
    var old_health := _current_health
    var new_health := min(_current_health + heal_amount, MAX_HEALTH)

    _current_health = new_health

    emit_signal('health_changed', old_health, new_health)
