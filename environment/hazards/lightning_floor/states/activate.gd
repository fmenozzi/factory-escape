extends 'res://actors/enemies/enemy_state.gd'

const ATTACK_DURATION := 0.5

onready var _timer: Timer = $AttackDuration

func _ready() -> void:
    _timer.one_shot = true
    _timer.wait_time = ATTACK_DURATION

func enter(lightning_floor: LightningFloor, previous_state_dict: Dictionary) -> void:
    lightning_floor.get_hitbox_collision_shape().set_deferred('disabled', false)
    for bolt in lightning_floor.get_bolts():
        bolt.reactivate()
        bolt.resume()
    lightning_floor.get_bolts_node().modulate.a = 1

    _timer.start()

func exit(lightning_floor: LightningFloor) -> void:
    lightning_floor.get_hitbox_collision_shape().set_deferred('disabled', true)

func update(lightning_floor: LightningFloor, delta: float) -> Dictionary:
    if _timer.is_stopped():
        return {'new_state': LightningFloor.State.NEXT_STATE_IN_SEQUENCE}

    return {'new_state': LightningFloor.State.NO_CHANGE}
