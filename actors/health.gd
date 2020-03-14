extends Node
class_name Health

signal health_changed(old_health, new_health)
signal died

export(int) var MAX_HEALTH := 5

var _current_health: int

enum Status {
    NONE,
    INVINCIBLE,
}
var _current_status: int

func _ready() -> void:
    _current_health = MAX_HEALTH
    _current_status = Status.NONE

# Take damage if not invincible. Returns whether damage was taken.
func take_damage(damage_amount: int) -> bool:
    if _current_status == Status.INVINCIBLE:
        return false

    var old_health := _current_health
    var new_health := max(_current_health - damage_amount, 0)

    _current_health = new_health

    emit_signal('health_changed', old_health, new_health)
    if new_health == 0:
        emit_signal('died')

    return true

func heal(heal_amount: int) -> void:
    var old_health := _current_health
    var new_health := min(_current_health + heal_amount, MAX_HEALTH)

    _current_health = new_health

    emit_signal('health_changed', old_health, new_health)

func heal_to_full() -> void:
    var old_health := _current_health
    var new_health := MAX_HEALTH

    _current_health = MAX_HEALTH

    emit_signal('health_changed', old_health, new_health)

func set_status(new_status: int) -> void:
    assert(new_status in [Status.NONE, Status.INVINCIBLE])
    _current_status = new_status
